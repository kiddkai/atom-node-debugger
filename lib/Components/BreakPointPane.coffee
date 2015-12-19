hg = require 'mercury'
Promise = require 'bluebird'
{h} = hg

log = (msg) -> #console.log(msg)

{TreeView, TreeViewItem, TreeViewUtils} = require './TreeView'

gotoBreakpoint = (breakpoint) ->
  atom.workspace.open(breakpoint.script, {
    initialLine: breakpoint.line
    initialColumn: 0
    activatePane: true
    searchAllPanes: true
  })

exports.create = (_debugger) ->

  builder =
    listBreakpoints: () ->
      log "builder.listBreakpoints"
      Promise.resolve(_debugger.breakpointManager.breakpoints)

    breakpoint: (breakpoint) ->
      log "builder.breakpoint"
      TreeViewItem(
        TreeViewUtils.createFileRefHeader breakpoint.script, breakpoint.line+1
        handlers: { click: () -> gotoBreakpoint(breakpoint) }
      )
    root: () ->
      TreeView("Breakpoints", (() -> builder.listBreakpoints().map(builder.breakpoint)), isRoot: true)

  BreakpointPanel = () ->
    state = builder.root()
    refresh = () -> TreeView.populate(state)
    _debugger.onAddBreakpoint refresh
    _debugger.onRemoveBreakpoint refresh
    _debugger.onBreak refresh
    return state

  BreakpointPanel.render = (state) ->
    TreeView.render(state)

  BreakpointPanel.cleanup = () ->
    removeListener() if removeListener?

  return BreakpointPanel
