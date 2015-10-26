'use babel'

import hg from 'mercury'
import extend from 'xtend'
import { $ } from 'atom-space-pen-views'

function handleDrag (ev, broadcast) {
  let data = this.data
  let delegator = hg.Delegator()

  function onmove (ev) {
    let docHeight = $(document).height()
    let docWidth = $(document).width()
    let {pageY, pageX} = ev
    let statusBarHeight = $('div.status-bar-left').height()

    let delta = {
      height: docHeight - pageY - statusBarHeight,
      sideWidth: docWidth - pageX
    }

    broadcast(extend(data, delta))
  }

  function onup (ev) {
    delegator.unlistenTo('mousemove')
    delegator.removeGlobalEventListener('mousemove', onmove)
    delegator.removeGlobalEventListener('mouseup', onup)
  }

  delegator.listenTo('mousemove')
  delegator.addGlobalEventListener('mousemove', onmove)
  delegator.addGlobalEventListener('mouseup', onup)
}

export default hg.BaseEvent(handleDrag)
