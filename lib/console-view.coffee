{TextEditorView, View, $} = require 'atom'
debuggerContext = require './debugger'
VariableView = require './variable-view'
_ = require 'lodash'

ENTER_KEY = '\n'

module.exports =
class ConsoleView extends View

  @content: =>
    @div class: 'console-view', =>
      @div class: 'text-editor-wrapper', outlet: 'wrapper', =>
        @div outlet: 'logger'
      @subview 'inputter', new TextEditorView({ mini: false })


  initialize: ->

    @grammar = atom
                .syntax
                .grammarForScopeName('source.js')

    if not @grammar?
      @grammar = atom
                  .syntax
                  .grammarForScopeName('text.plain.null-grammar')

    if @grammar?
      @inputter
        .getModel()
        .setGrammar(@grammar)


    @disposeInputter = @inputter
      .getModel()
      .onWillInsertText @checkEval


  checkEval: (evt) =>
    return unless evt.text is ENTER_KEY

    text = @inputter
      .getModel()
      .getText()

    @appendLine(
      text
    )

    @eval text

    setTimeout =>
      @inputter
        .getModel()
        .setText('')

    evt.cancel()

  eval: (text) =>
    self = this

    debuggerContext
      .eval(text)
      .then((body) ->
        return self.appendLine(body.text) if body.type?
        self.logger.append(new VariableView(body))
      )
      .catch((err) ->
        self.appendLine(String(err))
      )
      .done()

  appendLine: (str) ->
    return unless str?
    $line = $('<div class="line">')

    tokens = @grammar.tokenizeLine(str).tokens;

    $line.append(
      tokens
        .map (token) ->
          $ch = $('<span>')
          $ch.text(token.value)
          $ch.addClass -> _.uniq(token.scopes.join(' ').split(/\W/)).join(' ')
          return $ch
    )

    @logger.append $line
    @wrapper.scrollTop(@logger.height())
