hg = require 'mercury'
{h} = hg

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

    h 'div.btn.btn-primary.inline-block-tight', {
      'ev-click': hg.send channels.next
      'data-type': state.type
      'distabled': !state.waiting
    }, [
      state.title()
    ]

  return StepButton
