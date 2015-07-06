{TextEditorView} = require 'atom-space-pen-views'
Event = require 'geval/event'
{merge, split} = require 'event-stream'
stream = require 'stream'
hg = require 'mercury'
{h} = hg

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

  class HistoryTracker
    constructor: (editor) ->
      @editor = editor
      @cmdHistory = []
      @cmdHistoryIndex = -1

    update: (text) ->
      if not(@cmdHistoryIndex >= 0 and
             @cmdHistoryIndex < @cmdHistory.length and
             @cmdHistory[@cmdHistoryIndex] is text)
        @cmdHistoryIndex = @cmdHistory.length
        @cmdHistory.push text
      @historyMode = false
    moveUp: ->
      if @cmdHistoryIndex > 0 and @historyMode
        @cmdHistoryIndex--
      @editor.setText(@cmdHistory[@cmdHistoryIndex])
      @historyMode = true
    moveDown: ->
      if @cmdHistoryIndex < @cmdHistory.length - 1 and @historyMode
        @cmdHistoryIndex++
      @editor.setText(@cmdHistory[@cmdHistoryIndex])
      @historyMode = true

  class ConsoleInput
    constructor: (@debugger)->
      @type = "Widget"
      @_changer = Event()
      @onEvalOrResult = @_changer.listen

    init: ->
      self = this
      @editorView = new TextEditorView(mini: true)
      @editor = @editorView.getModel()
      @historyTracker = new HistoryTracker(@editor)

      @editorView.on 'keyup', (ev) ->
        {keyCode} = ev
        switch keyCode
          when 13
            text = self.editor.getText()
            self._changer.broadcast(text)
            self.editor.setText('')
            self.historyTracker.update(text)
            self
              .debugger
              .eval(text)
              .then (result) ->
                self._changer.broadcast(result.text)
              .catch (e) ->
                self._changer.broadcast(e.message)
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

    _debugger.processManager.on 'procssCreated', ->
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
        flex: 'auto'
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
