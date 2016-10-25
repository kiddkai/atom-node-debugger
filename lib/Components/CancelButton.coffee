hg = require 'mercury'
{h} = hg

exports.create = (_debugger) ->

  cancel = () ->
    _debugger.cleanup()

  hg.state({
    channels: {
      cancel: cancel
    }
  })

exports.render = (state) ->
  h('button.btn.btn-error.icon-primitive-square', {
    'ev-click': hg.send state.channels.cancel
    'title': 'stop debugging'
  }, [])
