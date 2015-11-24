{EventEmitter} = require 'events'

log = (msg) -> # console.log(msg)

EventEmitter::subscribe = (event, handler) ->
    log "EventEmitter.subscribe"
    self = this
    self.on event, handler
    return (() -> self.removeListener event, handler)

EventEmitter::subscribeDisposable = (event, handler) ->
    log "EventEmitter.subscribeDisposable"
    self = this
    self.on event, handler
    return { dispose: -> self.removeListener event, handler }

exports.EventEmitter = EventEmitter
