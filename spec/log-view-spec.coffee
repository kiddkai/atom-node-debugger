{EventEmitter} = require 'events'
from = require 'from'

LogView = require '../lib/log-view'
debuggerContext = require '../lib/debugger'

describe 'Log View', ->

  logView = null
  runnerStub = null
  procStub = null

  outEnd = false
  errEnd = false

  beforeEach ->
    runner = debuggerContext.runner
    runnerStub = new EventEmitter

    runnerStub.proc =
      stdout: from (count, next)->
        this.emit('data', 'this is a stdout line\n')
        if (outEnd)
          this.emit('end')

        outEnd = true
        next()

      stderr: from (count, next)->
        this.emit('data', 'this is a stderr line\n')

        if (errEnd)
          this.emit('end')

        errEnd = true
        next()

    debuggerContext.runner = runnerStub
    logView = new LogView

    outEnd = false
    errEnd = false


    debuggerContext.runner = runner

  it 'should be able to toggle selected when click on the log type', ->
    expect(logView.find('.selected').data('logtype')).toBe('stdout')
    logView.find("[data-logtype='stderr']").click()
    expect(logView.find('.selected').data('logtype')).toBe('stderr')

    logView.find("[data-logtype='stdout']").click()
    expect(logView.find('.selected').data('logtype')).toBe('stdout')

  it 'should be able to change logtype for log view', ->
    expect(logView.hasClass('stdout')).toBeTruthy()

    logView.find("[data-logtype='stderr']").click()
    expect(logView.hasClass('stdout')).toBeFalsy()
    expect(logView.hasClass('stderr')).toBeTruthy()

    logView.find("[data-logtype='stdout']").click()
    expect(logView.hasClass('stderr')).toBeFalsy()
    expect(logView.hasClass('stdout')).toBeTruthy()

  it 'should be able to get the stdout from process', ->
    waitsFor ->
      outEnd

    runs ->
      expect(logView.find('.log.stdout').text()).toMatch(/this is a stdout line/)

  it 'should be able to get the stderr from process', ->
    waitsFor ->
      outEnd

    runs ->
      expect(logView.find('.log.stderr').text()).toMatch(/this is a stderr line/)
