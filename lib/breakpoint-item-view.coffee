{View} = require 'atom'
editorUtil = require './editor-util'
debuggerContext = require './debugger'

module.exports =
class BreakpointItemView extends View
  @content: (breakpoint) ->
    @tr class: "breakpoint-item-view details", =>
      @td class: 'number', "#{breakpoint.number}"
      @td class: 'path', "loading..."
      @td class: 'line', "#{breakpoint.line}"

  initialize: (breakpoint) ->
    that = this
    @breakpoint = breakpoint
    @scripts = debuggerContext.scripts
    @on 'click', @goToFile

    handleScriptLoad = (script) ->
      that.find('.path').text(script.name)
      that.script = script

    if breakpoint.type is 'scriptId'
      @scripts
        .getById(breakpoint.scriptId)
        .then handleScriptLoad

    else if breakpoint.type is 'scriptName'
      handleScriptLoad({
        name: breakpoint.scriptName
      })

  goToFile: =>
    editorUtil.jumpToFile({
      name: @script.name
    }, @breakpoint.line);
