{View, $} = require 'atom'
debuggerContext = require './debugger'


module.exports =
class FrameView extends View

  @content (variable): =>
    @li class:'variable-view', =>
      @span outlet: 'variable-name', variable.name
      if variable.value.ref?
        @div outlet: 'variable-value', 'not populated'
      else
        @div outlet: 'variable-value', variable.value.value
        @div outlet: 'variable-type', "[#{variable.value.type}]"

  initialize: ->
