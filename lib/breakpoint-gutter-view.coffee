{Subscriber} = require 'emissary'
debuggerContext = require './debugger'

module.exports =
class BreakpointGutterView
  Subscriber.includeInto(this)

  constructor: (@editorView) ->
    {@editor, @gutter} = @editorView
    {@breakpoints} = debuggerContext

    @subscribe @editorView, 'editor:path-changed', => @updateBreakpoint()
    @subscribe @editorView, 'editor:will-be-removed', => @unscribe()
    @subscribe @breakpoints, 'change', => @updateBreakpoint()

    @updateBreakpoint()


  updateBreakpoint: ->
    path = @editor.getPath()

    for breakpoint in @breakpoints.getBreakpoints()
      if breakpoint.script_name is @editor.getPath()
        @gutter.addClassToLine(breakpoint.line, 'gutter-breakpoint')
