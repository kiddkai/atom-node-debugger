{View, $, $$} = require 'atom'
q = require 'q'
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
    @name.text("#{variable.name}")
    @render()
    @expend = false
    @isObject = false
    @on 'click', (e) => e.stopPropagation()
    @on 'click', @toggle

  toggle: (e) =>
    return if not @isObject
    @expend = not @expend
    @render()

  render: =>
    @value.empty()
    variable = @variable
    self = this

    @variable
      .populate()
      .then (variable) =>
        value = variable.value

        if value.type is 'object'
          self.isObject = true
          text = '{ Object .. }'
          self.addClass('list-nested-item').addClass('collapsed')
          $props = $('<ul class="list-tree">')
          self.append($props)

          if self.expend is true
            text = ''
            self.removeClass('collapsed')
            for prop in value.properties
              $props.append(new VariableView(prop))

        else if value.type is 'function'
          text = 'Function'
        else
          text = value.text

        self.value.text(text)

      .done()
