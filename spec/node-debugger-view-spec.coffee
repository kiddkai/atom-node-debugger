{WorkspaceView, Workspace} = require 'atom'
{EventEmitter} = require 'events'
NodeDebuggerView = require '../lib/node-debugger-view'
debuggerContext = require '../lib/debugger'
editorUtil = require '../lib/editor-util'


describe "NodeDebuggerView", ->

  view = null
  scriptsStub = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView;
    scripts = debuggerContext.scripts
    scriptsStub = new EventEmitter

    debuggerContext.scripts = scriptsStub
    view = new NodeDebuggerView

    spyOn(editorUtil, 'jumpToFile')

  it 'should be able to try to jump to the breakpoint', ->
    scriptStub = {}

    scriptsStub.emit('break', scriptStub, 10)

    expect(editorUtil.jumpToFile).toHaveBeenCalledWith(scriptStub, 10);
