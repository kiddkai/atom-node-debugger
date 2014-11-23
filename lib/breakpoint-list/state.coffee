{EventEmitter} = require 'events'
Context = require '../debugger'

module.exports =
class BreakpointListState extends EventEmitter
  constructor: ->
    @breakpoints = []
    @manager = Context.breakpoints
    @update()

  get: ->
    return @breakpoints

  disable: (breakpoint) ->

  enable: (breakpoint) ->

  update: ->
    self = this
    @manager
      .fetch()
      .then (brks) =>
        self.breakpoints = brks
