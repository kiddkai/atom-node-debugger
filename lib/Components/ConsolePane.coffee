{TextEditorView} = require 'atom-space-pen-views'
Event = require 'geval/event'
{merge, split} = require 'event-stream'
stream = require 'stream'
hg = require 'mercury'
{h} = hg
{CommandHistory} = require './consolepane-utils'

exports.create = (_debugger) ->
  jsGrammar = atom.grammars.grammarForScopeName('source.js')

  tokenizeLine = (text) ->
    {tokens} = jsGrammar.tokenizeLine(text)
    h('div.line', {}, [
      h('span.test.shell-session', {}, tokens.map((token) ->
        h('span', {
          className: token.scopes.join(' ').split('.').join(' ')
        }, [token.value])
      ))
    ])

  class ConsoleInput
    constructor: (@debugger)->
      @type = "Widget"
      @_changer = Event()
      @onEvalOrResult = @_changer.listen

    init: ->
      self = this
      @editorView = new TextEditorView(mini: true)
      @editor = @editorView.getModel()
      @historyTracker = new CommandHistory(@editor)

      @editorView.on 'keyup', (ev) ->
        {keyCode} = ev
        switch keyCode
          when 13
            text = self.editor.getText()
            self._changer.broadcast(text)
            self.editor.setText('')
            self.historyTracker.saveIfNew(text)
            self
              .debugger
              .eval(text)
              .then (result) ->
                self._changer.broadcast(result.text)
              .catch (e) ->
                if e.message?
                  self._changer.broadcast(e.message)
                else
                  self._changer.broadcast(e)
          when 38
            self.historyTracker.moveUp()
          when 40
            self.historyTracker.moveDown()

      return @editorView.get(0)

    update: (prev, el) ->
      return el

  input = new ConsoleInput(_debugger)

  ConsolePane = () ->
    state = hg.state({
      lines: hg.array([])
    })

    input.onEvalOrResult (text) ->
      state.lines.push(text)

    newWriter = () ->
      new stream.Writable({
        write: (chunk, encoding, next) ->
          state.lines.push(chunk.toString())
          next()
      })

    _debugger.processManager.on 'processCreated', ->
      {stdout, stderr} = _debugger.processManager.process

      stdout.on 'data', (d) -> console.log(d.toString())
      stderr.on 'data', (d) -> console.log(d.toString())

      stdout
        .pipe(split())
        .pipe(newWriter())

      stderr
        .pipe(split())
        .pipe(newWriter())

    return state

  ConsolePane.render = (state) ->
    h('div.inset-panel', {
      style: {
        flex: '1 1 0'
        display: 'flex'
        flexDirection: 'column'
      }
    }, [
      h('div.debugger-panel-heading', {}, ['stdout/stderr'])
      h('div.panel-body.padded', style: {
        flex: '1'
        overflow: 'auto'
      }, state.lines.map(tokenizeLine))
      h('div.debugger-editor', style: {
        height: '33px'
        flexBasis: '33px'
      }, [
        input
      ])
    ])

  return ConsolePane

exports.cleanup = () ->
