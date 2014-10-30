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

  it 'should be able to get the stdout from process', ->
    waitsFor ->
      outEnd

    runs ->
      expect(logView.stdoutView.logger.text()).toMatch(/this is a stdout line/)

  it 'should be able to get the stderr from process', ->
    waitsFor ->
      outEnd

    runs ->
      expect(logView.stdoutView.logger.text()).toMatch(/this is a stderr line/)
