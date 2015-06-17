R = require 'ramda'
psTree = require 'ps-tree'
Promise = require 'bluebird'
{Client} = require '_debugger'
childprocess = require 'child_process'
{EventEmitter} = require 'events'
Event = require 'geval/event'
logger = require './logger'

class ProcessManager extends EventEmitter
  constructor: (@atom = atom)->
    super()
    @process = null

  start: (file) ->
    @cleanup()
      .then =>
        nodePath = @atom.config.get('atom-node-debugger.nodePath')
        appArgs = @atom.config.get('atom-node-debugger.appArgs')
        port = @atom.config.get('atom-node-debugger.debugPort')
        isCoffee = @atom.config.get('atom-node-debugger.isCoffeeScript')

        appPath = @atom
          .workspace
          .getActiveTextEditor()
          .getPath()

        args = [
          "--debug-brk=#{port}"
          file or appPath
          appArgs or ''
        ]

        # for coffee-script debugging
        if isCoffee
          args = [
            '--nodejs'
            "--debug-brk=#{port}"
            file or appPath
            appArgs or ''
          ]

        @process = childprocess.spawn nodePath, args, {
          detached: true
        }

        @process.stdout.on 'data', (d) ->
          logger.info 'child_process', d.toString()

        @process.stderr.on 'data', (d) ->
          logger.info 'child_process', d.toString()

        @process.stdout.on 'end', () ->
          logger.info 'child_process', 'end out'

        @process.stderr.on 'end', () ->
          logger.info 'child_process', 'end errror'

        @emit 'procssCreated', @process

        @process.once 'error', (e) =>
          logger.info 'child_process error', e
          @emit 'processEnd', e

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

      onProcessEnd = R.once =>
        logger.info 'child_process', 'die'
        @emit 'processEnd', @process
        @process = null
        resolve()

      logger.info 'child_process', 'start killing process'
      psTree @process.pid, (err, children) =>
        logger.info 'child_process_children', children
        childprocess.spawn 'kill', ['-9'].concat(children.map((p) -> p.PID))
        self.process.kill() if self.process?


      @process.once 'disconnect', onProcessEnd
      @process.once 'exit', onProcessEnd
      @process.once 'close', onProcessEnd

class Debugger extends EventEmitter
  constructor: (@atom = atom, @processManager)->
    super()
    @breakpoints = []
    @client = null

    @onBreakEvent = Event()
    @onAddBreakpointEvent = Event()
    @onRemoveBreakpointEvent = Event()
    @onBreak = @onBreakEvent.listen
    @onAddBreakpoint = @onAddBreakpointEvent.listen
    @onRemoveBreakpoint = @onRemoveBreakpointEvent.listen
    @processManager.on 'procssCreated', @start
    @processManager.on 'processEnd', @cleanup
    @markers = []

  stopRetrying: ->
    return unless @timeout?
    clearTimeout @timeout


  listBreakpoints: ->
    new Promise (resolve, reject) =>
      @client.listbreakpoints (err, res) ->
        return reject(err) if err
        resolve(res.breakpoints)

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

  tryGetBreakpoint: (script, line) =>
    findMatch = R.find (breakpoint) =>
      if breakpoint.scriptId is script or breakpoint.scriptReq is script or (breakpoint.script and breakpoint.script.indexOf(script) isnt -1)
        return breakpoint.line is (line+1);
    return findMatch(@client.breakpoints)

  toggleBreakpoint: (editor, script, line) ->
    new Promise (resolve, reject) =>

      match = @tryGetBreakpoint(script, line)
      if match
        @clearBreakPoint(script, line)
      else
        @addBreakpoint(editor, script, line)

  addBreakpoint: (editor, script, line, condition, silent) =>
    new Promise (resolve, reject) =>
      if script is undefined
        script = @client.currentScript;
        line = @client.currentSourceLine + 1

      if line is undefined and typeof script is 'number'
        line = script
        script = @client.currentScript

      return if not script?

      if /\(\)$/.test(script)
        req =
          type: 'function'
          target: script.replace /\(\)$/, ''
          confition: condition
      else
        if script != +script && not @client.scripts[script]
          scripts = @client.scripts
          for id in scripts
            if scripts[id] and scripts[id].name and scripts.name.indexOf(script) isnt -1
              ambiguous = scriptId?
              scriptId = id
            else
              scriptId = script

      if line <= 0
        return reject(new Error('Line should be a positive value'))
      if ambiguous
        return reject(new Error('Invalid script name'))

      if scriptId?
        req =
          type: 'scriptId'
          target: scriptId
          line: line - 1
          condition: condition
      else
        escapedPath = script.replace(/([/\\.?*()^${}|[\]])/g, '\\$1')
        scriptPathRegex = "^(.*[\\/\\\\])?#{escapedPath}$";
        req =
          type: 'script'
          target: script
          line: line
          condition: condition

      @client.setBreakpoint req, (err, res) =>
        return reject(err) if err

        if not scriptId?
          scriptId = res.script_id
          line = res.line + 1

        brk =
          id: res.breakpoint
          scriptId: scriptId
          script: (@client?.scripts?[scriptId] or {}).name
          line: line,
          condition: condition,
          scriptReq: script

        @client.breakpoints.push brk
        brk.marker = @markLine(editor, brk)
        @onAddBreakpointEvent.broadcast(brk)
        resolve(brk)


  clearBreakPoint: (script, line) ->
    self = this
    getbrk =
      () ->
        new Promise (resolve, reject) =>
              match = self.tryGetBreakpoint(script, line)
              return reject() if not match?
              resolve({
                    breakpoint: match
                    index: self.client.breakpoints.indexOf match
                  })
    clearbrk =
      (brk) ->
        new Promise (resolve, reject) =>
            self.client.clearBreakpoint { breakpoint: brk.breakpoint.id }, (err) =>
              return reject(err) if err
              self.client.breakpoints.splice brk.index, 1
              markerIndex = self.markers.indexOf(brk.breakpoint.marker)
              self.markers.splice(markerIndex, 1)
              brk.breakpoint.marker.destroy()
              self.onRemoveBreakpointEvent.broadcast(brk)
              resolve()

    getbrk().then(clearbrk)

  fullTrace: () ->
    new Promise (resolve, reject) =>
      @client.fullTrace (err, res) ->
        return reject(err) if err
        resolve(res)

  start: =>
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
        self.atom.config.get('atom-node-debugger.debugPort'),
        self.atom.config.get('atom-node-debugger.debugHost')
      )

    onConnectionError = =>
      logger.info 'debugger', "trying to reconnect #{attemptConnectCount}"
      attemptConnectCount++
      @emit 'reconnect', attemptConnectCount
      @timeout = setTimeout =>
        attemptConnect()
      , 500

    @client = new Client()
    @client.once 'ready', @bindEvents

    @client.on 'unhandledResponse', (res) => @emit 'unhandledResponse', res
    @client.on 'break', (res) =>
      @onBreakEvent.broadcast(res.body)
      @emit 'break', res.body
    @client.on 'exception', (res) => @emit 'exception', res.body
    @client.on 'error', onConnectionError
    @client.on 'close', () ->
      logger.info 'client', 'client closed'

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
      @client.req {
        command: 'evaluate'
        arguments: {
          expression: text
        }
      }, (err, result) ->
        return reject(err) if err
        return resolve(result)

  cleanup: =>
      return unless @client?
      @removeBreakpointMarkers()
      @removeDecorations()
      @client.destroy()
      @client = null
      @emit 'disconnected'

  markLine: (editor, breakPoint) ->
      marker = editor.markBufferPosition([breakPoint.line-1, 0], invalidate: 'never')
      editor.decorateMarker(marker, type: 'line-number', class: 'node-debugger-breakpoint')
      @markers.push marker
      return marker

  removeBreakpointMarkers: =>
      return unless @client?
      breakpoint.marker.destroy() for breakpoint in @client.breakpoints

  removeDecorations: ->
      return unless @markers?
      marker.destroy() for marker in @markers
      @markers = []

  isConnected: =>
      return @client?

exports.ProcessManager = ProcessManager
exports.Debugger = Debugger
