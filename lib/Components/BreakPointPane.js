'use babel'

/** @jsx h */

import Promise from 'bluebird'
import { TreeView, TreeViewItem } from './TreeView'

function gotoBreakpoint (brk) {
  let { line } = brk
  let { name } = brk.script

  atom.workspace.open(name, {
    initialLine: line,
    initialColumn: 0,
    activatePane: true,
    searchAllPanes: true
  })
}

export function create (_debugger) {
  let builder = {
    listBreakpoints () {
      return _debugger
        .listBreakpoints()
        .then(brks =>
          Promise.map(brks, brk => {
            if (brk.script_id) {
              return _debugger.getScriptById(brk.script_id)
                .then(script => {
                  brk.script = script
                  return brk
                })
            } else if (brk.script_name) {
              brk.script = { name: brk.script_name }
            }
            return brk
          }))
    },

    breakpoint (breakpoint) {
      return TreeViewItem(
        `${breakpoint.script.name} : (${breakpoint.line + 1})`, {
          handlers: { click: () => gotoBreakpoint(breakpoint) }
        })
    },

    root () {
      return TreeView(
        'Breakpoints',
        () => builder.listBreakpoints().map(builder.breakpoint),
        { isRoot: true })
    }
  }

  let BreakpointPanel = () => {
    let state = builder.root()
    let refresh = () => TreeView.populate(state)
    _debugger.onAddBreakpoint(refresh)
    _debugger.onRemoveBreakpoint(refresh)
    _debugger.onBreak(refresh)
    return state
  }

  BreakpointPanel.render = (state) => {
    return TreeView.render(state)
  }

  BreakpointPanel.cleanup = () => {}

  return BreakpointPanel
}
