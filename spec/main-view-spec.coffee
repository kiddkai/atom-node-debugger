MainView = require '../lib/main-view'
Debugger = require '../lib/debugger'
{EventEmitter} = require 'events'

describe 'MainView', ->
  mainView = null
  runnerStub = null
  connectionStub = null

  beforeEach ->
    runner = Debugger.runner
    connection = Debugger.connection

    runnerStub = new EventEmitter
    connectionStub = new EventEmitter

    Debugger.runner = runnerStub
    Debugger.connection = connectionStub

    mainView = new MainView

    Debugger.runner = runner
    Debugger.connection = connection

  it 'should be able to show loading view when runner started', ->
    runnerStub.proc = {}
    expect(mainView.find('.config-view')).toExist()
    runnerStub.emit('change');
    expect(mainView.find('.config-view')).not.toExist()
    expect(mainView.find('.loading-view')).toExist()

  it 'should show the config view again when runner got error', ->
    runnerStub.proc = {}
    expect(mainView.find('.config-view')).toExist()
    runnerStub.emit('change');
    expect(mainView.find('.config-view')).not.toExist()
    runnerStub.emit('error');
    expect(mainView.find('.config-view')).toExist()

  it 'should show the config view when runner changed and without proc', ->
    runnerStub.proc = null
    expect(mainView.find('.config-view')).toExist()
    runnerStub.emit('change');
    expect(mainView.find('.config-view')).toExist()

  it 'should able to show the functional page when connection started', ->
    connectionStub._connected = true
    connectionStub.emit 'change'
    expect(mainView.find('.config-view')).not.toExist()
    expect(mainView.find('.functional-view')).toExist()


  it 'should shows the config view when the connection change to non connected', ->
    connectionStub._connected = false
    connectionStub.emit 'change'
    expect(mainView.find('.config-view')).toExist()


  it 'should shows the config view when connection error', ->
    connectionStub._connected = false
    connectionStub.emit 'error'
    expect(mainView.find('.config-view')).toExist()
