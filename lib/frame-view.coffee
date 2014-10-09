{View, $} = require 'atom'
debuggerContext = require './debugger'


module.exports =
class FrameView extends View

  @content: =>
    @div class:'frames-view', =>
      @ul class: 'frames-arguments', outlet: 'argumentList'
      @ul class: 'frames-variables', outlet: 'variableList'

  initialize: ->
    @frames = debuggerContext.frames
    @frames.refresh().done()
    @frames.on 'change', @render

  beforeRemove: ->
    @frames.removeListener 'change', @render

  render: =>
    self = this
    item = @frames.get()
    @argumentList.empty()

    item.arguments.forEach (variable) =>
      self.argumentList.append($('<li>').text(variable.name))
