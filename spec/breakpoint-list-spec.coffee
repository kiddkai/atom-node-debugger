BreakpointList = require '../lib/breakpoint-list'
BreakpointListState = require '../lib/breakpoint-list/state'
Context = require '../lib/debugger'
q = require 'q'

describe "Breakpoint List", ->

  describe "State", ->
    it "should save the fetch result", ->
      promise = q([{}, {}])
      spyOn(Context.breakpoints, 'fetch').andReturn(q([{},{}]))
      bl = new BreakpointListState()

      waitsForPromise -> promise
      runs ->
        expect(bl.get().length).toBe(2)

  describe "List", ->
    it "should fetch breakpoints", ->
      spyOn(Context.breakpoints, 'fetch').andReturn(q([]))
      bl = new BreakpointList()
      expect(Context.breakpoints.fetch).toHaveBeenCalled()
