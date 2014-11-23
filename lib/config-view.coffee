{View, TextEditorView} = require 'atom'
which = require 'which'
debuggerContext = require './debugger'
{spawn} = require 'child_process'

module.exports =
class ConfigView extends View
  @content: ->
    @div class: "config-view", =>
      @div "node path"
      @subview 'nodePathInput', new TextEditorView(mini: true)

      @div "application path"
      @subview 'appPathInput', new TextEditorView(mini: true)

      @div "arguments"
      @subview 'argumentInput', new TextEditorView(mini: true)

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
        @findByShell (err, path) =>
          console.error(err) if err?
          @nodePathInput.getEditor().setText(path) if path?

      else
        @nodePathInput.getEditor().setText(path)

    @appPathInput.getEditor().setText(atom.workspace.getActiveEditor().getPath())



  findByShell: (fn) ->
    nvm = process.env.NVM_BIN

    if nvm?
      return fn null, "#{nvm}/node"

    shell = process.env.SHELL
    path = ''
    if shell?
      sh = spawn shell, ['-s', '-l']
      echo = spawn 'echo', ['which', 'node']

      echo.stdout.pipe(sh.stdin)

      sh
        .stdout
        .on 'data', (chunk) =>
          path += chunk.toString()

      sh
        .stdout
        .on 'end', () =>
          if not path?
            return fn null, nodePath

          fn(null, path)

    else
      fn(new Error('Shell is not found'))

  startRunning: ->
    @runner.start
      nodePath: @nodePathInput.getEditor().getText()
      runPath: @appPathInput.getEditor().getText()
      args: @argumentInput.getEditor().getText()

  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.appendToBottom(this)
