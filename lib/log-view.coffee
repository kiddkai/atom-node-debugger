{View, $} = require 'atom'
through = require 'through2'
split = require 'split'
debugContext = require './debugger'


module.exports =
class LogView extends View

  @content: =>
    @div class: 'log-view stdout', =>
      @div class: 'inset-panel log stdout', outlet: "stdoutView"

  initialize: ->
    @on 'click', '[data-logtype]', (e) => @switchLogType(e)

    @runner = debugContext.runner

    if (@runner.proc)
      @listenOutput(@runner.proc)

    @runner.on 'change', => @listenOutput(@runner.proc)

  listenOutput: (proc)->
    return if not proc?

    self = this

    ['stdout', 'stderr'].forEach (outType) ->
      onLine = (chunk, enc, callback) ->
        chunk = chunk.toString('utf-8')
        $para = $('<p>')
        $para.text(chunk)
        $para.appendTo(self.stdoutView)
        callback()

      proc[outType].pipe(split()).pipe(through(onLine))
