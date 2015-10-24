hg = require 'mercury'
Promise = require 'bluebird'
{h} = hg

log = (msg) -> #console.log(msg)

{TreeView, TreeViewItem} = require './TreeView'

gotoBreakpoint = (brk) ->
  {line} = brk
  {name} = brk.script
  atom.workspace.open(name, {
    initialLine: line
    initialColumn: 0
    activatePane: true
    searchAllPanes: true
  })

exports.create = (_debugger) ->

  builder =
    listBreakpoints: () ->
      log "builder.listBreakpoints"
      _debugger.listBreakpoints()
        .then (brks) ->
          Promise.map brks, (brk) ->
            log("processing breakpoint " + JSON.stringify(brk))
            if brk.script_id?
              return _debugger.getScriptById(brk.script_id)
                .then (script) ->
                  brk.script = script
                  return brk
            else if brk.script_name
              brk.script = { name: brk.script_name }
            return brk

    breakpoint: (breakpoint) ->
      log "builder.breakpoint"
      TreeViewItem("#{breakpoint.script.name} : (#{breakpoint.line + 1})", handlers: { click: () -> gotoBreakpoint(breakpoint) })

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
