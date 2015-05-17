hg = require 'mercury'
extend = require 'xtend'
{$} = require 'atom-space-pen-views'

handleDrag = (ev, broadcast) ->
  data = this.data
  delegator = hg.Delegator()

  onmove = (ev) ->
    docHeight = $(document).height()
    {pageY} = ev

    delta = {
      height: docHeight - pageY
    }

    broadcast(extend(data, delta))

  onup = (ev) ->
    delegator.unlistenTo 'mousemove'
    delegator.removeGlobalEventListener 'mousemove', onmove
    delegator.removeGlobalEventListener 'mouseup', onup


  delegator.listenTo 'mousemove'
  delegator.addGlobalEventListener 'mousemove', onmove
  delegator.addGlobalEventListener 'mouseup', onup

module.exports = hg.BaseEvent(handleDrag)
