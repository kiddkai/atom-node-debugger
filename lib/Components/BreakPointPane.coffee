hg = require 'mercury'
Promise = require 'bluebird'
{h} = hg

listeners = []

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
    listeners.push _debugger.onAddBreakpoint refresh
    listeners.push _debugger.onRemoveBreakpoint refresh
    listeners.push _debugger.onBreak refresh
    return state

  BreakpointPanel.render = (state) ->
    TreeView.render(state)

  BreakpointPanel.cleanup = () ->
    for remove in listeners
      remove()

  return BreakpointPanel
