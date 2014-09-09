{View} = require 'atom'
debuggerContext = require './debugger'
BreakpointItemView = require './breakpoint-item-view'

module.exports =
class BreakpointView extends View
  @content: ->
    @div class: "breakpoint-view", =>
      @table =>
        @thead =>
          @tr =>
            @th "number"
            @th "path"
            @th "line"
        @tbody outlet: 'breakpointList'

  initialize: ->
    @breakpoints = debuggerContext.breakpoints
    @breakpoints.on 'change', => @showBreakpoints()

  showBreakpoints: ->
    @breakpointList.empty()

    for breakpoint in @breakpoints.getBreakpoints()
      @breakpointList.append(new BreakpointItemView(breakpoint))
