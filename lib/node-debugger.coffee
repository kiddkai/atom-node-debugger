NodeDebuggerView = require './node-debugger-view'
{CompositeDisposable} = require 'atom'
{Debugger, ProcessManager} = require './debugger'
jumpToBreakpoint = require './jump-to-breakpoint'
logger = require './logger'
os = require 'os'

processManager = null
_debugger = null
onBreak = null

module.exports =
  nodeDebuggerView: null
  config:
    nodePath:
      type: 'string'
      default: if os.platform() is 'win32' then 'node.exe' else '/bin/node'
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
      default: ''
    scriptMain:
      type: 'string'
      default: ''
    appArgs:
      type: 'string'
      default: ''
    isCoffeeScript:
      type: 'boolean'
      default: false
    env:
      type: 'string'
      default: ''

  activate: () ->
    @disposables = new CompositeDisposable()
    processManager = new ProcessManager(atom)
    _debugger = new Debugger(atom, processManager)
    @disposables.add _debugger.subscribeDisposable 'connected', ->
      atom.notifications.addSuccess('connected, enjoy debugging : )')
    @disposables.add _debugger.subscribeDisposable 'disconnected', ->
      atom.notifications.addInfo('finish debugging : )')
    @disposables.add atom.commands.add('atom-workspace', {
      'node-debugger:start-resume': @startOrResume
      'node-debugger:start-active-file': @startActiveFile
      'node-debugger:stop': @stop
      'node-debugger:toggle-breakpoint': @toggleBreakpoint
      'node-debugger:step-next': @stepNext
      'node-debugger:step-in': @stepIn
      'node-debugger:step-out': @stepOut
    })

    jumpToBreakpoint(_debugger)

  startOrResume: =>
    if _debugger.isConnected()
      _debugger.reqContinue()
    else
      processManager.start()
      NodeDebuggerView.show(_debugger)

  startActiveFile: =>
    if _debugger.isConnected()
      return
    else
      processManager.startActiveFile()
      NodeDebuggerView.show(_debugger)

  toggleBreakpoint: =>
    editor = atom.workspace.getActiveTextEditor()
    path = editor.getPath()
    {row} = editor.getCursorBufferPosition()
    _debugger.breakpointManager.toggleBreakpoint editor, path, row

  stepNext: =>
    _debugger.step('next', 1) if _debugger.isConnected()

  stepIn: =>
    _debugger.step('in', 1) if _debugger.isConnected()

  stepOut: =>
    _debugger.step('out', 1) if _debugger.isConnected()

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
    _debugger.dispose()

  serialize: ->
    nodeDebuggerViewState: @nodeDebuggerView.serialize()
