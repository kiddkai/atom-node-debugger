{View, $} = require 'atom'
through = require 'through2'
split = require 'split'
debugContext = require './debugger'
ConsoleView = require './console-view'


module.exports =
class LogView extends View

  @content: =>
    @div class: 'log-view stdout', =>
      @subview 'stdoutView', new ConsoleView

  initialize: ->
    @on 'click', '[data-logtype]', (e) => @switchLogType(e)

    @runner = debugContext.runner

    if (@runner.proc)
      @listenOutput(@runner.proc)

    @runner.on 'change', @listenOutput

  beforeRemove: ->
    @runner.removeListener 'change', @listenOutput

  listenOutput: () =>
    return unless @runner.proc
    proc = @runner.proc
    self = this

    ['stdout', 'stderr'].forEach (outType) ->
      onLine = (chunk, enc, callback) ->
        chunk = chunk.toString('utf-8')
        self
          .stdoutView
          .appendLine(chunk)

        callback()

      proc[outType].pipe(split()).pipe(through(onLine))
