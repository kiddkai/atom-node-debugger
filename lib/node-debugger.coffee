NodeDebuggerView = require './node-debugger-view'
BreakpointGutterView = require './breakpoint-gutter-view'

module.exports =
  nodeDebuggerView: null

  activate: (state) ->
    @nodeDebuggerView = new NodeDebuggerView(state.nodeDebuggerViewState)
    atom.workspaceView.eachEditorView (ev) ->
      new BreakpointGutterView(ev)
      
  deactivate: ->
    @nodeDebuggerView.destroy()

  serialize: ->
    nodeDebuggerViewState: @nodeDebuggerView.serialize()
