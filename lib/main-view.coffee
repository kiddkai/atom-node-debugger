{View} = require 'atom'
debuggerContext = require './debugger'
ConfigView = require './config-view'
LoadingView = require './loading-view'
FunctionalView = require './functional-view'

module.exports =
class MainView extends View
  @content: ->
    @div class: "main-view"

  initialize: (serializeState) ->
    @runner = debuggerContext.runner
    @connection = debuggerContext.connection

    @append(new ConfigView)

    @runner.on 'change', => @showLoading()
    @runner.on 'error', => @showConfig()
    @connection.on 'change', => @onConnectionChange()

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

  onConnectionChange: ->
    @empty()
    @append(new FunctionalView)

  showLoading: ->
    @empty()
    @append(new LoadingView)

  showConfig: ->
    @empty()
    @append(new ConfigView)
