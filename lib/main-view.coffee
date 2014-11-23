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

    @runner.on 'change', @showLoading
    @runner.on 'error', @showConfig
    @connection.on 'change', @onConnectionChange
    @connection.on 'error', @onConnectionChange

  beforeRemove: ->
    @runner.removeListener 'change', @showLoading
    @runner.removeListener 'error', @showConfig
    @connection.removeListener 'change', @onConnectionChange
    @connection.removeListener 'change', @onConnectionChange

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  onConnectionChange: =>
    @empty()
    if @connection._connected
      @append(new FunctionalView)
    else
      @append(new ConfigView)

  showLoading: =>
    return unless @runner.proc?
    @empty()
    @append(new LoadingView)

  showConfig: =>
    @empty()
    @append(new ConfigView)
