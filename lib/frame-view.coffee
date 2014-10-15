{View, $, $$} = require 'atom'
debuggerContext = require './debugger'
VariableView = require './variable-view'

module.exports =
class FrameView extends View

  @content: =>
    @ul class:'frames-view list-tree has-collapsable-children', =>
      @li class: 'frames-arguments list-nested-item', outlet: 'argumentList'
      @li class: 'frames-variables list-nested-item', outlet: 'variableList'

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
    @variableList.empty()

    @argumentList.append $$ ->
      @div class: 'list-item', =>
        @text 'Arguments'

    if item? and item.arguments?
      @argumentList.append $$ ->
        @ul class: 'list-tree', =>
          for variable in item.arguments
            @subview 'variable', new VariableView(variable)

    @variableList.append $$ ->
      @div class: 'list-item', =>
        @text 'Locals'

    if item? and item.locals?
      @variableList.append $$ ->
        @ul class: 'list-tree', =>
          for variable in item.locals
            @subview 'variable', new VariableView(variable)
