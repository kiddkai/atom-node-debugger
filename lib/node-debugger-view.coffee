{View} = require 'atom'
MainView = require './main-view'
debuggerContext = require './debugger'
editorUtil = require './editor-util'


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

    atom.workspaceView.on "contextmenu", ".line-number", @selectLine

  serialize: ->

  destroy: ->
    @mainView.destroy()
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.appendToBottom(this)

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

  selectLine: (e) ->
    activeEditor = atom.workspace.getActiveEditor()
    row = parseInt(e.target.getAttribute "data-buffer-row", 10)

    activeEditor.setCursorBufferPosition {
    	row: row,
    	column: activeEditor.getCursorBufferPosition().column
    }

