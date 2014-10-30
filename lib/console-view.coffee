{TextEditorView, View, $} = require 'atom'
ENTER_KEY = '\n'

module.exports =
class ConsoleView extends View

  @content: =>
    @div class: 'console-view', =>
      @div class: 'text-editor-wrapper', =>
        @subview 'logger', new TextEditorView({ mini: false })
      @subview 'inputter', new TextEditorView({ mini: false })


  initialize: ->

    @grammer = atom
                .syntax
                .grammarForScopeName('source.js')

    if @grammer?
      @logger
        .getModel()
        .setGrammar(@grammer)

      @inputter
        .getModel()
        .setGrammar(@grammer)
        
    @logger
      .component
      .setShowLineNumbers(false)


    @disposeInputter = @inputter
      .getModel()
      .onWillInsertText @checkEval

    @logger.setInputEnabled(false)

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


  appendLine: (str) ->
    log = @logger.getModel()

    line = log.getLineCount()
    log.moveDown(line)
    log.insertText(str)
    log.insertNewline()
