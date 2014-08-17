LogView = require '../lib/log-view'

describe 'Log View', ->

  logView = null

  beforeEach ->
    logView = new LogView

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
