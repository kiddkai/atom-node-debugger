'use babel'

/** @jsx h */

import hg, { h } from 'mercury'

const BTN_ICON_MAP = {
  'continue': 'icon-playback-play btn btn-primary',
  'next': 'icon-chevron-right btn btn-primary',
  'out': 'icon-chevron-up btn btn-primary',
  'in': 'icon-chevron-down btn btn-primary'
}

export function StepButton (_debugger) {
  let onNext = (state) => {
    state.waiting(true)

    let type = state.type()
    let promise = null

    if (type === 'continue') {
      promise = _debugger.reqContinue()
    } else {
      promise = _debugger.step(type, 1)
    }

    return promise
      .then(() => state.waiting(false))
      .catch(e => state.waiting(false))
  }

  let stepButton = (name, type) => hg.state({
    title: hg.value(name),
    type: hg.value(type),
    waiting: hg.value(false),
    channels: {
      next: onNext
    }
  })

  stepButton.render = (state) => {
    let channels = state.channels()

    return (
      <div
        ev-click={hg.send(channels.next)}
        className={BTN_ICON_MAP[state.type()]}
        distabled={!state.waiting}>
      </div>
    )
  }

  return stepButton
}
