{View, $} = require 'atom'
LogView = require './log-view'
BreakpointView = require './breakpoint-view'
debuggerContext = require './debugger'
FrameView = require './frame-view'

module.exports =
class FunctionalView extends View
  @content: ->
    @div class: "functional-view console", =>
      @div class: 'block', =>
        @div class: 'btn-group functional-controls', =>
          @button class: 'btn selected', 'data-functional': 'console', 'Console'
          @button class: 'btn', 'data-functional': 'breakpoint','Breakpoints'
          @button class: 'btn', 'data-functional': 'frame','Frame'

        @div class: 'btn-group', =>
          @button class: 'btn', 'data-continue': '', 'continue'
          @button class: 'btn', 'data-continue': 'in', 'step in'
          @button class: 'btn', 'data-continue': 'next', 'step next'
          @button class: 'btn', 'data-continue': 'out', 'step out'

        @div class: 'btn-group pull-right', =>
          @button class: 'btn btn-error', 'x'

      # panel area
      @div class: 'functional console inset-panel', =>
        @subview 'logView', new LogView

      @div class: 'functional breakpoint', =>
        @subview 'breakpointsView', new BreakpointView

      @div class: 'functional frame', =>
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
