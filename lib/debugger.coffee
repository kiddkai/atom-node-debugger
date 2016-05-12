R = require 'ramda'
path = require 'path'
kill = require 'tree-kill'
Promise = require 'bluebird'
{Client} = require '_debugger'
childprocess = require 'child_process'
{EventEmitter} = require './eventing'
Event = require 'geval/event'
logger = require './logger'
fs = require 'fs'
NodeDebuggerView = require './node-debugger-view'
jumpToBreakpoint = require './jump-to-breakpoint'

log = (msg) -> # console.log(msg)

class ProcessManager extends EventEmitter
  constructor: (@atom = atom)->
    super()
    @process = null

  parseEnv: (env) ->
    return null unless env
    key = (s) -> s.split("=")[0]
    value = (s) -> s.split("=")[1]
    result = {}
    result[key(e)] = value(e) for e in env.split(";")
    return result

  startActiveFile: () ->
    @start true

  start: (withActiveFile) ->
    startActive = withActiveFile
    @cleanup()
      .then =>
        packagePath = @atom.project.resolvePath('package.json')
        packageJSON = JSON.parse(fs.readFileSync(packagePath)) if fs.existsSync(packagePath)
        nodePath = @atom.config.get('node-debugger.nodePath')
        nodeArgs = @atom.config.get('node-debugger.nodeArgs')
        appArgs = @atom.config.get('node-debugger.appArgs')
        port = @atom.config.get('node-debugger.debugPort')
        env = @parseEnv @atom.config.get('node-debugger.env')
        scriptMain = @atom.project.resolvePath(@atom.config.get('node-debugger.scriptMain'))

        dbgFile = scriptMain || packageJSON && @atom.project.resolvePath(packageJSON.main)

        if startActive == true || !dbgFile
          editor = @atom.workspace.getActiveTextEditor()
          appPath = editor.getPath()
          dbgFile = appPath

        cwd = path.dirname(dbgFile)

        args = []
        args = args.concat (nodeArgs.split(' ')) if nodeArgs
        args.push "--debug-brk=#{port}"
        args.push dbgFile
        args = args.concat (appArgs.split(' ')) if appArgs

        logger.error 'spawn', {args:args, env:env}
        @process = childprocess.spawn nodePath, args, {
          detached: true
          cwd: cwd
          env: env if env
        }

        @process.stdout.on 'data', (d) ->
          logger.info 'child_process', d.toString()

        @process.stderr.on 'data', (d) ->
          logger.info 'child_process', d.toString()

        @process.stdout.on 'end', () ->
          logger.info 'child_process', 'end out'

        @process.stderr.on 'end', () ->
          logger.info 'child_process', 'end error'

        @emit 'processCreated', @process

        @process.once 'error', (err) =>
          switch err.code
            when "ENOENT"
              logger.error 'child_process', "ENOENT exit code. Message: #{err.message}"
              atom.notifications.addError(
                "Failed to start debugger.
                Exit code was ENOENT which indicates that the node
                executable could not be found.
                Try specifying an explicit path in your atom config file
                using the node-debugger.nodePath configuration setting."
              )
            else
              logger.error 'child_process', "Exit code #{err.code}. #{err.message}"
          @emit 'processEnd', err

        @process.once 'close', () =>
          logger.info 'child_process', 'close'
          @emit 'processEnd', @process

        @process.once 'disconnect', () =>
          logger.info 'child_process', 'disconnect'
          @emit 'processEnd', @process

        return @process

  cleanup: ->
    self = this
    new Promise (resolve, reject) =>
      return resolve() if not @process?
      if @process.exitCode
        logger.info 'child_process', 'process already exited with code ' + @process.exitCode
        @process = null
        return resolve()

      onProcessEnd = R.once =>
        logger.info 'child_process', 'die'
        @emit 'processEnd', @process
        @process = null
        resolve()

      logger.info 'child_process', 'start killing process'
      kill @process.pid

      @process.once 'disconnect', onProcessEnd
      @process.once 'exit', onProcessEnd
      @process.once 'close', onProcessEnd

class BreakpointManager
  constructor: (@debugger) ->
    log "BreakpointManager.constructor"
    self = this
    @breakpoints = []
    @client = null
    @removeOnConnected = @debugger.subscribe 'connected', ->
      self.client = self.debugger.client
      log "BreakpointManager.connected #{@client}"
      self.attachBreakpoint breakpoint for breakpoint in self.breakpoints
    @removeOnDisconnected = @debugger.subscribe 'disconnected', ->
      log "BreakpointManager.disconnected"
      self.client = null
      for breakpoint in self.breakpoints
        breakpoint.id = null
        self.decorateBreakpoint breakpoint
    @onAddBreakpointEvent = Event()
    @onRemoveBreakpointEvent = Event()

  dispose: () ->
    @removeOnConnected() if @removeOnConnected
    @removeOnConnected = null
    @removeOnDisconnected() if @removeOnDisconnected
    @removeOnDisconnected = null

  toggleBreakpoint: (editor, script, line) ->
    log "BreakpointManager.toggleBreakpoint #{script}, #{line}"
    maybeBreakpoint = @tryFindBreakpoint script, line
    if maybeBreakpoint
      @removeBreakpoint maybeBreakpoint.breakpoint, maybeBreakpoint.index
    else
      @addBreakpoint editor, script, line

  removeBreakpoint: (breakpoint, index) ->
    log "BreakpointManager.removeBreakpoint #{index}"
    @breakpoints.splice index, 1
    @onRemoveBreakpointEvent.broadcast breakpoint
    @detachBreakpoint breakpoint, 'removed'

  addBreakpoint: (editor, script, line) ->
    log "BreakpointManager.addBreakpoint #{script}, #{line}"
    breakpoint =
      script: script
      line: line
      marker: null
      editor: editor
      id: null
    log "BreakpointManager.addBreakpoint - adding to list"
    @breakpoints.push breakpoint
    log "BreakpointManager.addBreakpoint - adding default decoration"
    @decorateBreakpoint breakpoint
    log "BreakpointManager.addBreakpoint - publishing event, num breakpoints=#{@breakpoints.length}"
    @onAddBreakpointEvent.broadcast breakpoint
    log "BreakpointManager.addBreakpoint - attaching"
    @attachBreakpoint breakpoint

  attachBreakpoint: (breakpoint) ->
    log "BreakpointManager.attachBreakpoint"
    self = this
    new Promise (resolve, reject) ->
      return resolve() unless self.client
      log "BreakpointManager.attachBreakpoint - client request"
      self.client.setBreakpoint {
        type: 'script'
        target: breakpoint.script
        line: breakpoint.line
        condition: breakpoint.condition
      }, (err, res) ->
        log "BreakpointManager.attachBreakpoint - done"
        return reject(err) if err
        breakpoint.id = res.breakpoint
        self.decorateBreakpoint breakpoint
        resolve(breakpoint)

  detachBreakpoint: (breakpoint, reason) ->
    log "BreakpointManager.detachBreakpoint"
    self = this
    new Promise (resolve, reject) ->
      id = breakpoint.id
      breakpoint.id = null
      breakpoint.marker.destroy()
      breakpoint.marker = null
      return resolve() unless self.client
      return resolve() unless id
      log "BreakpointManager.detachBreakpoint - client request"
      self.client.clearBreakpoint {
        breakpoint: id
      }, (err) ->
         self.decorateBreakpoint breakpoint unless reason is 'removed'
        resolve()

  tryFindBreakpoint: (script, line) ->
    return { breakpoint: breakpoint, index: i } for breakpoint, i in @breakpoints when breakpoint.script is script and breakpoint.line is line

  decorateBreakpoint: (breakpoint) ->
    log "BreakpointManager.decorateBreakpoint - #{breakpoint.marker is null}"
    breakpoint.marker.destroy() if breakpoint.marker
    breakpoint.marker = breakpoint.editor.markBufferPosition([breakpoint.line, 0], invalidate: 'never')
    className = if breakpoint.id then 'node-debugger-attached-breakpoint' else 'node-debugger-detached-breakpoint'
    breakpoint.editor.decorateMarker(breakpoint.marker, type: 'line-number', class: className)

class Debugger extends EventEmitter
  constructor: (@atom)->
    super()
    @client = null
    @breakpointManager = new BreakpointManager(this)
    @onBreakEvent = Event()
    @onBreak = @onBreakEvent.listen
    @onAddBreakpoint = @breakpointManager.onAddBreakpointEvent.listen
    @onRemoveBreakpoint = @breakpointManager.onRemoveBreakpointEvent.listen
    @processManager = new ProcessManager(@atom)
    @processManager.on 'processCreated', @attachInternal
    @processManager.on 'processEnd', @cleanupInternal
    @onSelectedFrameEvent = Event()
    @onSelectedFrame = @onSelectedFrameEvent.listen
    @selectedFrame = null
    jumpToBreakpoint(this)

  getSelectedFrame: () => @selectedFrame
  setSelectedFrame: (frame, index) =>
      @selectedFrame = {frame, index}
      @onSelectedFrameEvent.broadcast(@selectedFrame)

  dispose: ->
    @breakpointManager.dispose() if @breakpointManager
    @breakpointManager = null
    NodeDebuggerView.destroy()
    jumpToBreakpoint.destroy()

  stopRetrying: ->
    return unless @timeout?
    clearTimeout @timeout

  step: (type, count) ->
    self = this
    new Promise (resolve, reject) =>
      @client.step type, count, (err) ->
        return reject(err) if err
        resolve()

  reqContinue: ->
    self = this
    new Promise (resolve, reject) =>
      @client.req {
        command: 'continue'
      }, (err) ->
        return reject(err) if err
        resolve()

  getScriptById: (id) ->
    self = this
    new Promise (resolve, reject) =>
      @client.req {
        command: 'scripts',
        arguments: {
          ids: [id],
          includeSource: true
        }
      }, (err, res) ->
        return reject(err) if err
        resolve(res[0])


  fullTrace: () ->
    new Promise (resolve, reject) =>
      @client.fullTrace (err, res) ->
        return reject(err) if err
        resolve(res)

  start: =>
      @debugHost = "127.0.0.1"
      @debugPort = @atom.config.get('node-debugger.debugPort')
      @externalProcess = false
      NodeDebuggerView.show(this)
      @processManager.start()
      # debugger will attach when process is started

  startActiveFile: =>
      @debugHost = "127.0.0.1"
      @debugPort = @atom.config.get('node-debugger.debugPort')
      @externalProcess = false
      NodeDebuggerView.show(this)
      @processManager.startActiveFile()
      # debugger will attach when process is started

  attach: =>
    @debugHost = @atom.config.get('node-debugger.debugHost')
    @debugPort = @atom.config.get('node-debugger.debugPort')
    @externalProcess = true
    NodeDebuggerView.show(this)
    @attachInternal()

  attachInternal: =>
    logger.info 'debugger', 'start connect to process'
    self = this
    attemptConnectCount = 0
    attemptConnect = ->
      logger.info 'debugger', 'attempt to connect to child process'
      if not self.client?
        logger.info 'debugger', 'client has been cleanup'
        return
      attemptConnectCount++
      self.client.connect(
        self.debugPort,
        self.debugHost
      )

    onConnectionError = =>
      logger.info 'debugger', "trying to reconnect #{attemptConnectCount}"
      timeout = 500
      @emit 'reconnect', {
        count: attemptConnectCount
        port: self.debugPort
        host: self.debugHost
        timeout: timeout
      }
      @timeout = setTimeout =>
        attemptConnect()
      , timeout

    @client = new Client()
    @client.once 'ready', @bindEvents

    @client.on 'unhandledResponse', (res) => @emit 'unhandledResponse', res
    @client.on 'break', (res) =>
      @onBreakEvent.broadcast(res.body); @emit 'break', res.body
      @setSelectedFrame(null)

    @client.on 'exception', (res) => @emit 'exception', res.body
    @client.on 'error', onConnectionError
    @client.on 'close', () -> logger.info 'client', 'client closed'

    attemptConnect()

  bindEvents: =>
    logger.info 'debugger', 'connected'
    @emit 'connected'
    @client.on 'close', =>
      logger.info 'debugger', 'connection closed'

      @processManager.cleanup()
        .then =>
          @emit 'close'

  lookup: (ref) ->
    new Promise (resolve, reject) =>
      @client.reqLookup [ref], (err, res) ->
        return reject(err) if err
        resolve(res[ref])

  eval: (text) ->
    new Promise (resolve, reject) =>
      @client.reqFrameEval text, @selectedFrame?.index or 0, (err, result) ->
        return reject(err) if err
        return resolve(result)

  cleanup: =>
    @processManager.cleanup()
    NodeDebuggerView.destroy()
    @cleanupInternal()

  cleanupInternal: =>
    @client.destroy() if @client
    @client = null
    jumpToBreakpoint.cleanup()
    @emit 'disconnected'

  isConnected: =>
      return @client?

exports.Debugger = Debugger
exports.ProcessManager = ProcessManager
