{View} = require 'atom'
MainView = require './main-view'

module.exports =
class NodeDebuggerView extends View
  @content: ->
    @div class: "node-debugger panel", =>
      @div class: "panel-heading", "Node Debugger"
      @div class: "panel-body padded" , =>
        @subview 'mainView', new MainView

  initialize: (serializeState) ->
    atom.workspaceView.command "node-debugger:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.appendToBottom(this)
