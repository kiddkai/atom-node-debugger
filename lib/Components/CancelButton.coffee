hg = require 'mercury'
{h} = hg

exports.create = (_debugger) ->

  cancel = () ->
    _debugger.processManager.cleanup()

  hg.state({
    channels: {
      cancel: cancel
    }
  })

exports.render = (state) ->
  h('button.btn.btn-error', {
    'ev-click': hg.send state.channels.cancel
  }, ['x'])
