debuggerContext = require '../debugger'
{EventEmitter} = require 'events'

module.exports =
class BreakpointGutter extends EventEmitter

  constructor: ->
    @manager = debuggerContext.breakpoints
    @runner = debuggerContext.runner

    @runner.on 'change', @checkIfNeedsCleanup
    @gutters = []

    @subscribe()

  update: =>
    return unless @runner.proc?

    @manager
      .fetch()
      .then (breakpoints) =>
        @gutters = breakpoints
          .filter (brk) ->
            atom.project.contains(brk.scriptName)
          .map (brk) ->
            return {
              path: brk.scriptName
              line: brk.line + 1
            }

        @emit 'change'
      .done()

  subscribe: ->
    @manager.on 'change', @update

  checkIfNeedsCleanup: =>
    if not @runner.proc
      @cleanup()
    else
      @subscribe()

  cleanup: ->
    @manager.removeListener 'change', @update

  destroy: ->
    @cleanup()
    @runner.removeListener 'change', @checkIfNeedsCleanup
