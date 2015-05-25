hg = require 'mercury'
{h} = hg

BTN_ICON_MAP = {
  'continue': 'icon-playback-play btn btn-primary'
  'next': 'icon-chevron-right btn btn-primary'
  'out': 'icon-chevron-up btn btn-primary'
  'in': 'icon-chevron-down btn btn-primary'
}

exports.StepButton = (_debugger) ->
  onNext = (state) ->
    type = state.type()
    state.waiting(true)
    promise = null

    if type is 'continue'
      promise = _debugger.reqContinue()
    else
      promise = _debugger.step(type, 1)

    promise.then ->
      state.waiting(false)
    .catch (e) ->
      state.waiting(false)

  StepButton = (name, type) ->
    hg.state({
      title: hg.value(name)
      type: hg.value(type)
      waiting: hg.value(false)
      channels: {
        next: onNext
      }
    })

  StepButton.render = (state) ->
    channels = state.channels()

    h 'div', {
      'ev-click': hg.send channels.next
      'className': BTN_ICON_MAP[state.type()]
      'distabled': !state.waiting
    }, [
    ]

  return StepButton
