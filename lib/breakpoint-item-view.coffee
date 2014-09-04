{View} = require 'atom'
debuggerContext = require './debugger'

module.exports =
class BreakpointItemView extends View
  @content: (breakpoint) ->
    @li class: "breakpoint-item-view", =>
      @div class: "details", =>
        @span class: 'number', "#{breakpoint.number}"
        @span class: 'path', "loading..."
        @span class: 'line', "#{breakpoint.line}"

      @div class: "loading", =>
        @span "loading ..."


  initialize: (breakpoint) ->
    that = this
    @breakpoint = breakpoint
    @scripts = debuggerContext.scripts
    @addClass('loading')

    handleScriptLoad = (script) ->
      that.find('.path').text(script.name)
      that.removeClass('loading')

    if breakpoint.type is 'scriptId'
      @scripts
        .getById(breakpoint.scriptId)
        .then handleScriptLoad

    else if breakpoint.type is 'scriptName'
      handleScriptLoad({
        name: breakpoint.scriptName
      })
