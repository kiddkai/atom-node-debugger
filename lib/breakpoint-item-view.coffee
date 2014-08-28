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
    @breakpoint = breakpoint
    @scripts = debuggerContext.scripts

    @addClass('loading')

    handleScriptLoad = (script) =>
      @find('.path').text(script.name)
      @removeClass('loading')

    return if not script?

    if breakpoint.type is 'scriptId'
      @scripts
        .getById(breakpoint.script_id)
        .then handleScriptLoad

    else if breakpoint.type is 'scriptName'
      @scripts
        .getByName(breakpoint.script_name)
        .then handleScriptLoad

    else
      @find('.path').text(script.name)
      @removeClass('loading')
