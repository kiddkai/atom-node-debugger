{View} = require 'atom'
debuggerContext = require './debugger'
ConfigView = require './config-view'

module.exports =
class MainView extends View
  @content: ->
    @div class: "main-view", =>
      @subview 'configView', new ConfigView

  initialize: (serializeState) ->
    @runner = debuggerContext.runner
    @connection = debuggerContext.connection

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
