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
    atom.workspaceView.command "node-debugger:breakpoint-toggle", =>
      @toggleBreakpoint()

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
    else
      atom.workspaceView.appendToBottom(this)

  toggleBreakpoint: ->
