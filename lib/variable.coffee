debuggerContext = require './debugger'
q = require 'q'
_ = require 'lodash'


module.exports =
class Variable

  # input with v8 variable object
  constructor: (obj) ->
    @_isPopulated = true

    if obj.value.ref instanceof Number
      @ref = obj.value.ref
      @_isPopulated = false

    properties = []

    @value = obj.value
    @name = obj.name

    if obj.value.properties? and obj.value.properties.length
      for prop in obj.value.properties
        properties.push new Variable({
          name: prop.name
          value:
            ref: prop.ref
        })

    @value.properties = properties

  # populate the variable values
  populate: ->
    self = this
    connection = debuggerContext.connection

    connection
      .lookup([@ref])
      .then (populated) ->
        self._isPopulated = true
        populated = populated[0]
        populated.properties = _.map populated.properties, (p) ->
          new Variable({
            name: p.name
            value:
              ref: p.ref
          })

        self.value = populated
        return populated

  populateProps: ->
    self = this
    props = self.value.properties
    connection = debuggerContext.connection

    refs = props.map (prop) -> prop.value.ref

    return q(self) if self._propPopulated

    connection
      .lookup(refs)
      .then (propsObj) ->
        self._propPopulated = true
        for prop in props
          prop.value = propsObj[prop.value.ref]
        return self


  isPopulated: ->
    @_isPopulated

  isPropPopulated: ->
    @_propPopulated
