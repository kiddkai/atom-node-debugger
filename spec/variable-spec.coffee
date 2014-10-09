debuggerContext = require '../lib/debugger'
Variable = require '../lib/variable'
q = require 'q'

describe 'Variable', ->

  describe '::isPopulated', ->
    describe 'when variable has only a ref', ->
      it 'should false', ->
        v = new Variable({
          value:
            ref: 10
        })
        expect(v.isPopulated()).toBeFalsy()


  describe '::populate', ->
    describe 'when start populate', ->
      v = null

      beforeEach ->
        v = new Variable({
          value:
            ref: 10
        })

        spyOn(debuggerContext.connection, 'lookup')
          .andReturn(q([{
            properties: [{
              name: 'something',
              ref: 10
            }],
            prototypeObject: {},
            text: '#<Object>',
            type: 'object'
          }]))


        waitsForPromise ->
          v.populate()


      it 'should start lookup the value if it', ->
        expect(debuggerContext.connection.lookup).toHaveBeenCalled()

      it 'should assign the properties to v.value', ->
        expect(v.value.properties.length).toBe(1)

      it 'should initialize the properties as Variable object', ->
        expect(v.value.properties[0] instanceof Variable).toBeTruthy()
