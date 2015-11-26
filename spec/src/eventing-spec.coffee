{EventEmitter} = require '../../lib/eventing'

class TestEmitter extends EventEmitter
  emitTestEvent: ->
    @emit 'testEvent', "some data"

describe 'EventEmitter', ->
  describe '.subscribe', ->
    it 'should return an unsubscribe function', ->
      emitter = new TestEmitter()
      eventCounter = 0
      unsubscribe = emitter.subscribe 'testEvent', (data) -> eventCounter = eventCounter + 1
      emitter.emitTestEvent()
      expect(eventCounter).toEqual(1)
      unsubscribe()
      emitter.emitTestEvent()
      expect(eventCounter).toEqual(1)
  describe '.subscribeDisposable', ->
    it 'should return an subscribe object', ->
      emitter = new TestEmitter()
      eventCounter = 0
      subscription = emitter.subscribeDisposable 'testEvent', (data) -> eventCounter = eventCounter + 1
      emitter.emitTestEvent()
      expect(eventCounter).toEqual(1)
      subscription.dispose()
      emitter.emitTestEvent()
      expect(eventCounter).toEqual(1)
