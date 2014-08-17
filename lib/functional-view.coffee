{View} = require 'atom'

module.exports =
class FunctionalView extends View
  @content: ->
    @div class: "functional-view", =>
      @div class: 'block', =>
        @div class: 'btn-group', =>
          @button class: 'btn selected', 'Console'
          @button class: 'btn', 'Debug'
          @button class: 'btn', 'Frame'

        @div class: 'btn-group pull-right', =>
          @button class: 'btn btn-error', 'x'
