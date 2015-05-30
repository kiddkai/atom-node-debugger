childprocess = require 'child_process'
{EventEmitter} = require 'events'
{ProcessManager} = require '../../lib/debugger'
Stream = require 'stream'

makeFakeProcess = () ->
  process = new EventEmitter()
  process.stdout = new Stream()
  process.stderr = new Stream()

  return process

describe 'ProcessManager', ->
  describe '.start', ->
    it 'starts a process base on the atom config and if no file specify', ->

      mapping = {
        'atom-node-debugger.nodePath': '/bin/node'
        'atom-node-debugger.appArgs': '--name'
        'atom-node-debugger.debugPort': 5858
      }

      atomStub =
        workspace:
          getActiveTextEditor: ->
            getPath: -> '/path/to/file.js'
        config:
          get: (key) -> mapping[key]

      spyOn(childprocess, 'spawn').andReturn(makeFakeProcess())

      manager = new ProcessManager(atomStub)
      waitsForPromise () ->
        manager.start().then () ->
          expect(childprocess.spawn).toHaveBeenCalled()
          expect(childprocess.spawn).toHaveBeenCalledWith('/bin/node')
