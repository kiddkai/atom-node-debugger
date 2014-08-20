{EventEmitter} = require 'events'

BreakpointView = require '../lib/breakpoint-view'
debuggerContext = require '../lib/debugger'

describe 'Breakpoint View', ->

  breakpointView = null
  breakpointsStub = null
  procStub = null

  beforeEach ->
    breakpoints = debuggerContext.breakpoints
    breakpointsStub = new EventEmitter

    debuggerContext.breakpoints = breakpointsStub
    breakpointView = new BreakpointView

    breakpointsStub.getBreakpoints = jasmine.createSpy().andReturn([{
      number: 1,
      line: 100,
      column: 10
      enabled: true
    }])

    debuggerContext.breakpoints = breakpoints

  it 'should be able to shows all the breakpoints in the list', ->
    expect(breakpointView.find('.breakpoint-item-view').length).toBe(0)
    breakpointsStub.emit('change')
    expect(breakpointView.find('.breakpoint-item-view').length).toBe(1)
