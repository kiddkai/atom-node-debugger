{View, $} = require 'atom'
LogView = require './log-view'
BreakpointView = require './breakpoint-view'
debuggerContext = require './debugger'
FrameView = require './frame-view'

module.exports =
class FunctionalView extends View
  @content: ->
    @div class: "functional-view info", =>
      @div class: 'block', =>
        @div class: 'btn-group functional-controls', =>
          @button class: 'btn', 'data-functional': 'info','info'
          @button class: 'btn selected', 'data-functional': 'console', 'Console'

        @div class: 'btn-group pull-right', =>
          @button class: 'btn', 'data-continue': '', 'continue'
          @button class: 'btn', 'data-continue': 'in', 'step in'
          @button class: 'btn', 'data-continue': 'next', 'step next'
          @button class: 'btn', 'data-continue': 'out', 'step out'
          @button class: 'btn btn-error', click: 'stopRunning', 'stop'

      # panel area
      @div class: 'functional console inset-panel', =>
        @subview 'logView', new LogView

      @div class: 'functional info', =>
        @subview 'breakpointsView', new BreakpointView
        @subview 'frameView', new FrameView


  initialize: ->
    self = this
    @on 'click', '[data-functional]', (e) => @toggleFunctional(e)
    @on 'click', '[data-continue]', (e) => @continue(e)

  toggleFunctional: (e) ->
    $prevSelected = @find('.functional-controls .selected')
    @removeClass($prevSelected.data('functional'))
    $prevSelected.removeClass('selected')

    $selected = $(e.target)
    @addClass($selected.data('functional'))
    $selected.addClass('selected')


  continue: (e) ->
    $el = $(e.target)
    action = $el.data('continue')
    debuggerContext.continue(action)

  stopRunning: (e) ->
    debuggerContext
      .runner
      .stop()
