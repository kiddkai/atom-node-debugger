{EventEmitter} = require 'events'
debuggerContext = require '../lib/debugger'
q = require 'q'

beforeEach ->
  spyOn(debuggerContext.frames, 'refresh')
    .andReturn(q(true))
