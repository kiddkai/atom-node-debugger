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
        'node-debugger.nodePath': '/path/to/node'
        'node-debugger.appArgs': '--name'
        'node-debugger.debugPort': 5860
      }

      atomStub =
        project:
          resolvePath: (file) -> '/path/to/file.js'
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
          # expect(childprocess.spawn).toHaveBeenCalledWith('/path/to/node', ['--debug-brk=5860', '/path/to/file.js', '--name', { detached : true }])
          # cannot get the toHaveBeenCalledWith to match the arguments so this method is used instead to verify the call
          expect(childprocess.spawn.mostRecentCall.args[0]).toEqual('/path/to/node')
          expect(childprocess.spawn.mostRecentCall.args[1][0]).toEqual('--debug-brk=5860')
          expect(childprocess.spawn.mostRecentCall.args[1][1]).toEqual('/path/to/file.js')
          expect(childprocess.spawn.mostRecentCall.args[1][2]).toEqual('--name')
