{View, $} = require 'atom'

module.exports =
class FunctionalView extends View
  @content: ->
    @div class: "functional-view console", =>
      @div class: 'block', =>
        @div class: 'btn-group', =>
          @button class: 'btn selected', 'data-functional': 'console', 'Console'
          @button class: 'btn', 'data-functional': 'debug','Debug'
          @button class: 'btn', 'data-functional': 'frames','Frame'

        @div class: 'btn-group pull-right', =>
          @button class: 'btn btn-error', 'x'

  initialize: ->
    self = this
    @on 'click', '[data-functional]', (e) => @toggleFunctional(e)

  toggleFunctional: (e) ->
    $prevSelected = @find('.selected')
    @removeClass($prevSelected.data('functional'))
    $prevSelected.removeClass('selected')

    $selected = $(e.target)
    @addClass($selected.data('functional'))
    $selected.addClass('selected')
