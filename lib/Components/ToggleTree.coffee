hg = require 'mercury'
{h} = hg

exports.state = (title) ->
  hg.state({
    title: hg.value(title)
    isOn: hg.value(false)
    channels: {
      toggle: exports.toggle
    }
  })

exports.toggle = (state) ->
  state.isOn.set(not state.isOn())

exports.render = (state, children) ->
  h('div.debugger-vertical-pane.breakpoint-pane.inset-panel', {
  }, [
    h('div', {
    }, [
      h('ul.list-tree.has-collapsable-children', {}, [
        h('li.list-nested-item', {
            className: if state.isOn then '' else 'collapsed'
          }, [
          h('div.list-item.heading', {
            'ev-click': hg.send state.channels.toggle
          }, [
            "#{state.title}"
          ])
        ].concat(children))
      ])
    ])
  ])
