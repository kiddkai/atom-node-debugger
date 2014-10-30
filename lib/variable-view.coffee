{View, $, $$} = require 'atom'
q = require 'q'
util = require './editor-util'
debuggerContext = require './debugger'

module.exports =
class VariableView extends View

  @content: =>
    @li class:'variable-view', =>
      @div class: 'list-item', =>
        @span outlet: 'name'
        @text ': '
        @span class: 'variable-value', outlet: 'value'

  initialize: (@variable) ->
    if not @variable.name
      @name.remove()
    else
      @name.text("#{@variable.name}")

    @render()
    @expend = false
    @isObject = false
    @on 'click', (e) => e.stopPropagation()
    @on 'click', @toggle

  toggle: (e) =>
    e.stopPropagation()
    return if not @isObject
    @expend = not @expend
    @render()

  render: =>
    @value.empty()
    variable = @variable
    self = this
    self.find('.variable-props').remove()
    @variable
      .populate()
      .then (variable) =>
        value = variable.value

        if value.type is 'object'
          self.isObject = true
          text = '{ Object .. }'
          self.addClass('list-nested-item').addClass('collapsed')

          if self.expend is true
            text = ''
            $props = $('<ul class="list-tree variable-props">')
            self.append($props)
            self.removeClass('collapsed')
            for prop in value.properties
              $props.append(new VariableView(prop))

        else
          wrapper = if value.type isnt 'string' then '' else '"'
          text = wrapper + value.text + wrapper

        self.value.append(util.colorize(text))
      .catch (e) =>
        console.log(e)
      .done()
