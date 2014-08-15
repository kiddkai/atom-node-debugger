NodeDebuggerView = require './node-debugger-view'

module.exports =
  nodeDebuggerView: null

  activate: (state) ->
    @nodeDebuggerView = new NodeDebuggerView(state.nodeDebuggerViewState)

  deactivate: ->
    @nodeDebuggerView.destroy()

  serialize: ->
    nodeDebuggerViewState: @nodeDebuggerView.serialize()
