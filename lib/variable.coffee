debuggerContext = require './debugger'
q = require 'q'
_ = require 'lodash'


module.exports =
class Variable

  # input with v8 variable object
  constructor: (obj) ->
    @_isPopulated = true

    if obj.value.ref instanceof Number
      console.log('not populated')
      @ref = obj.value.ref
      @_isPopulated = false

    @value = obj.value
    @name = obj.name

  # populate the variable values
  populate: ->
    self = this
    connection = debuggerContext.connection

    connection
      .lookup([@ref])
      .then (populated) ->
        @_isPopulated = true
        populated = populated[0]

        populated.properties = _.map populated.properties, (p) ->
          new Variable({
            name: p.name
            value:
              ref: p.ref
          })

        self.value = populated



  isPopulated: ->
    @_isPopulated
