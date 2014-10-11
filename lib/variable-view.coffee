{View, $, $$} = require 'atom'
debuggerContext = require './debugger'
Variable = require './variable'

module.exports =
class VariableView extends View

  @content: =>
    @li class:'variable-view list-nexted-item', =>
      @div class: 'list-item', =>
        @span outlet: 'name'
        @span class: 'variable-value', outlet: 'value'

  initialize: (variable) ->
    @variable = new Variable(variable)
    @name.text("#{@variable.name}: ");
    @render()


  render: =>
    variable = @variable

    @value.empty()
    @value.append =>
      switch variable.value.type
        when 'object' then return @renderObject()
        when 'undefined' then return @renderUndefined()
        when 'function' then return @renderFunction()
        else return @renderValue()

    @appendProperties() if variable.value.type is 'object' and variable.isPopulated()

  appendProperties: =>
    @empty()
    variable = @variable

    @append $$ ->
      @ul class: 'list-tree has-collapsable-children', =>
        @li class: 'list-nested-item collapsed', =>
          @div class: 'list-item', =>
            @text "#{variable.name}: Object"



  renderObject: =>
    variable = @variable
    $$ ->
      @text 'Object'

  renderUndefined: =>
    $$ ->
      @text 'undefined'

  renderValue: =>
    variable = @variable

    $$ ->
      @text "#{variable.value.value}"

  renderFunction: ->
    $$ ->
      @text 'Function'
