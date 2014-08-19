{View} = require 'atom'
debuggerContext = require './debugger'

module.exports =
class BreakpointItemView extends View
  @content: (breakpoint) ->
    @li class: "breakpoint-item-view", =>
      @div class: "details", =>
        @span class: 'number', "#{breakpoint.number}"
        @span class: 'path', "/path/to/js/file.js"
        @span class: 'line', "#{breakpoint.line}"

      @div class: "loading", =>
        @span "loading ..."


  initialize: (breakpoint) ->
    @breakpoint = breakpoint
