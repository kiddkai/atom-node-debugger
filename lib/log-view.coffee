{View, $} = require 'atom'

module.exports =
class LogView extends View

  @content: =>
    @div class: 'log-view stdout', =>
      @div class: 'btn-group', =>
        @button class: 'btn selected', 'data-logtype': 'stdout','stdout'
        @button class: 'btn', 'data-logtype': 'stderr','stderr'

  initialize: ->
    @on 'click', '[data-logtype]', (e) => @switchLogType(e)

  switchLogType: (e) ->
    $selected = @find('.selected')
    $selected.removeClass('selected')
    @removeClass($selected.data('logtype'))

    $selected = $(e.target)
    $selected.addClass('selected')
    @addClass($selected.data('logtype'))
