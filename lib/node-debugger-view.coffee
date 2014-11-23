{View} = require 'atom'
MainView = require './main-view'
debuggerContext = require './debugger'
editorUtil = require './editor-util'
BreakpointGutterView = require './breakpoint-gutter/view'


module.exports =
class NodeDebuggerView extends View
  @content: ->
    @div class: "node-debugger panel", =>
      @div class: "panel-heading", "Node Debugger"
      @div class: "panel-body padded" , =>
        @subview 'mainView', new MainView

  initialize: (serializeState) ->
    atom.workspaceView.command "node-debugger:toggle", => @toggle()
    atom.workspaceView.command "node-debugger:breakpoint-add", =>
      @addBreakpoint()

    @scripts = debuggerContext.scripts
    @scripts.on 'break', (script, line) =>
      editorUtil.jumpToFile(script, line)

  serialize: ->

  destroy: ->
    @mainView.destroy()
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
      if @gutterView
        @gutterView.destroy()
        @gutterView = null
    else
      atom.workspace.addBottomPanel({
        item: this
        visible: true
      })
      @gutterView = new BreakpointGutterView()

  addBreakpoint: ->
    activeEditor = atom.workspace.getActiveEditor()
    row = activeEditor.getCursorBufferPosition().row
    path = activeEditor.getPath()

    debuggerContext
      .breakpoints
      .create
        type: 'script'
        target: path
        line: row - 1
        column: 1
        enabled: true
      .then (breakpoint) ->
        # do nothing
