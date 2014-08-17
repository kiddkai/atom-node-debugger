{View} = require 'atom'

module.exports =
class FunctionalView extends View
  @content: ->
    @div class: "functional-view"
