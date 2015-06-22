hg = require 'mercury'
Promise = require 'bluebird'
{h} = hg

ToggleTree = require './ToggleTree'

exports.create = (_debugger) ->

  BreakpointPanel = () ->
    state = hg.state({
      rootToggle: ToggleTree.state('Breakpoints')
      breakpoints: hg.value([])
    })

    refresh = ->
      _debugger.listBreakpoints()
        .then (brks) ->
          Promise.map brks, (brk) ->
            if brk.script_id?
              return _debugger.getScriptById(brk.script_id)
                .then (script) ->
                  brk.script = script
                  return brk
            else if brk.script_name
              brk.script = { name: brk.script_name }

            return brk
          .then (brks) ->
            state.breakpoints.set(brks)


    _debugger.onAddBreakpoint refresh
    _debugger.onRemoveBreakpoint refresh
    _debugger.onBreak refresh

    return state

  BreakpointPanel.cleanup = () ->
    removeListener() if removeListener?

  goBreakpoint =  (brk) -> () ->
    {line} = brk
    {name} = brk.script

    atom.workspace.open(name, {
      initialLine: line
      initialColumn: 0
      activatePane: true
      searchAllPanes: true
    })

  BreakpointPanel.render = (state) ->
    renderBreakPoint = (brk) ->
      if (!brk.script)
        return h('li.list-item')
      h('li.list-item', {
        'ev-click': goBreakpoint(brk)
      }, [
        brk.script.name + ":" + (brk.line + 1)
      ]);

    brks = state.breakpoints.map(renderBreakPoint)

    ToggleTree.render(state.rootToggle, h('ul.list-tree', {}, brks))

  return BreakpointPanel
