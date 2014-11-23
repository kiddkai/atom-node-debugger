{View} = require 'atom'
State = require './state'

module.exports =
class BreakpointListView extends View
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
    @state = new State()
    
  showBreakpoints: ->
