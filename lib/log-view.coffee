{View, $} = require 'atom'
through = require 'through2'
split = require 'split'
debugContext = require './debugger'


module.exports =
class LogView extends View

  @content: =>
    @div class: 'log-view stdout', =>
      @div class: 'btn-group', =>
        @button class: 'btn selected', 'data-logtype': 'stdout','stdout'
        @button class: 'btn', 'data-logtype': 'stderr','stderr'


      @div class: 'inset-panel log stdout', outlet: "stdoutView"
      @div class: 'inset-panel log stderr', outlet: "stderrView"

  initialize: ->
    @on 'click', '[data-logtype]', (e) => @switchLogType(e)

    @runner = debugContext.runner

    if (@runner.proc)
      @listenOutput(@runner.proc)

    @runner.on 'change', => @listenOutput(runner.proc)

  switchLogType: (e) ->
    $selected = @find('.selected')
    $selected.removeClass('selected')
    @removeClass($selected.data('logtype'))

    $selected = $(e.target)
    $selected.addClass('selected')
    @addClass($selected.data('logtype'))

  listenOutput: (proc)->
    return if not proc?

    self = this

    ['stdout', 'stderr'].forEach (outType) ->
      onLine = (chunk, enc, callback) ->
        key = outType + 'View'
        chunk = chunk.toString('utf-8')
        console.log(chunk)
        $para = $('<p>')
        $para.text(chunk)
        $para.appendTo(self[key])
        callback()

      proc[outType].pipe(split()).pipe(through(onLine))
