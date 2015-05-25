NodeDebuggerView = require './node-debugger-view'
Event = require 'geval'
{CompositeDisposable} = require 'atom'
{Debugger, ProcessManager} = require './debugger'
jumpToBreakpoint = require './jump-to-breakpoint'
logger = require './logger'

processManager = null
_debugger = null
onBreak = null

initNotifications = (_debugger) ->
  _debugger.on 'connected', ->
    atom.notifications.addSuccess('connected, enjoy debugging : )')

  _debugger.on 'disconnected', ->
    atom.notifications.addInfo('finish debugging : )')

module.exports =
  nodeDebuggerView: null
  config:
    nodePath:
      type: 'string'
      default: '/bin/node'
    debugPort:
      type: 'number'
      minium: 5857
      maxium: 65535
      default: 5858
    debugHost:
      type: 'string'
      default: '127.0.0.1'
    nodeArgs:
      type: 'string'
    appArgs:
      type: 'string'
    isCoffeeScript:
      type: 'boolean'
      default: false

  activate: () ->
    @disposables = new CompositeDisposable()
    processManager = new ProcessManager(atom)
    _debugger = new Debugger(atom, processManager)
    initNotifications(_debugger)
    @disposables.add atom.commands.add('atom-workspace', {
      'node-debugger:debug-current-file': => @start(type: 'current')
      'node-debugger:debug-project': => @start(type: 'project')
      'node-debugger:stop': @stop
      'node-debugger:add-breakpoint': @addBreakpoint
      'node-debugger:remove-breakpoint': @removeBreakpoint
    })

    jumpToBreakpoint(_debugger)

  start: ({type}) =>
    afterStarted = null
    if type is 'project'
      afterStarted = @runProject()
    else
      afterStarted = processManager.start()

    NodeDebuggerView.show(_debugger)

  runProject: ->

  addBreakpoint: =>
    editor = atom.workspace.getActiveTextEditor()
    path = editor.getPath()
    {row} = editor.getCursorBufferPosition()
    _debugger.addBreakpoint(path, row)

  removeBreakpoint: =>

  stop: =>
    processManager.cleanup()
    _debugger.cleanup()
    NodeDebuggerView.destroy()
    jumpToBreakpoint.cleanup()

  deactivate: ->
    logger.info 'deactive', 'stop running plugin'
    jumpToBreakpoint.destroy()
    @stop()
    @disposables.dispose()
    NodeDebuggerView.destroy()

  serialize: ->
    nodeDebuggerViewState: @nodeDebuggerView.serialize()
