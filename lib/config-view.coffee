{View, EditorView} = require 'atom'
which = require 'which'
debuggerContext = require './debugger'


module.exports =
class ConfigView extends View
  @content: ->
    @div class: "config-view", =>
      @div "node path"
      @subview 'nodePathInput', new EditorView(mini: true)

      @div "application path"
      @subview 'appPathInput', new EditorView(mini: true)

      @div "arguments"
      @subview 'argumentInput', new EditorView(mini: true)

      @div class: "inset-panel padded", =>
        @div class: 'block', =>
          @button class: 'inline-block-tight btn', click: 'startRunning', 'Run'
          @button class: 'inline-block-tight btn', click: 'autoFill', 'Auto Fill'

  initialize: ->
    @runner = debuggerContext.runner
    @connection = debuggerContext.connection

  # Tear down any state and detach
  destroy: ->
    @detach()

  ##
  #
  # Auto fills in the options
  #
  #
  autoFill: ->
    which 'node', (err, path) =>
      if err?
        console.error('Node Can not be found in your path, please start atom in terminal')
      @nodePathInput.getEditor().setText(path)
    @appPathInput.getEditor().setText(atom.workspace.getActiveEditor().getPath())

  startRunning: ->
    @runner.start
      nodePath: @nodePathInput.getEditor().getText()
      runPath: @appPathInput.getEditor().getText()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.appendToBottom(this)
