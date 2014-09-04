{Subscriber} = require 'emissary'
debuggerContext = require './debugger'

module.exports =
class BreakpointGutterView
  Subscriber.includeInto(this)

  constructor: (@editorView) ->
    {@editor, @gutter} = @editorView
    {@breakpoints} = debuggerContext

    @subscribe @editorView, 'editor:path-changed', @subsribeBufferChange

    @subscribe @editorView, 'editor:will-be-removed', => @unsubscribe()
    @subscribe @breakpoints, 'change', @updateBreakpoint

    @subsribeBufferChange()


  subsribeBufferChange: =>
    @unsubscribeFromBuffer()

    if @buffer = @editor.getBuffer()
      @scheduleUpdate()
      @buffer.on 'contents-modified', @updateBreakpoint

  unsubscribeFromBuffer: =>
    if @buffer?
      @buffer.off 'contents-modified', @updateBreakpoint
      @buffer = null

  scheduleUpdate: ->
    @updateBreakpoint()

  updateBreakpoint: =>
    path = @editor.getPath()

    for breakpoint in @breakpoints.getBreakpoints()
      if breakpoint.scriptName is @editor.getPath()
        @gutter.addClassToLine(breakpoint.line, 'gutter-breakpoint')
