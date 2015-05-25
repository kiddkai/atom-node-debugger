{$, View, TextEditorView} = require 'atom-space-pen-views'
Module = require 'module'
path = require 'path'

removeModuleWrapper = (str) ->
  lines = str.split('\n');

  lines = lines.filter (line) ->
    return false if line is Module.wrapper[0]
    return true

  lines = lines.map (line) ->
    if line.indexOf(Module.wrapper[0]) >= 0
      return line.replace(Module.wrapper[0], '')
    return line

  popItem = null
  lines.pop()
  lines.join('\n')

module.exports =
class NonEditableEditorView extends TextEditorView
  @content: TextEditorView.content

  initialize: (opts) ->
    {
      @uri,
      @_debugger,
    } = opts

    if (opts.script)
      @id = opts.script.id
      @onDone()
      return @setText removeModuleWrapper(script.source)

    if (opts.id)
      @id = opts.id
      @_debugger
        .getScriptById(@id)
        .then (script) =>
          @script = script
          @setText removeModuleWrapper(script.source)
          @onDone()
        .then =>

    @title = opts.query.name

  onDone: ->
    extname = path.extname(@script.name)
    if extname is '.js'
      grammar = atom.grammars.grammarForScopeName('source.js')
    else if extname is '.coffee'
      grammar = atom.grammars.grammarForScopeName('source.coffee')
    else
      return

    @getModel().setGrammar(grammar)

  setCursorBufferPosition: (opts)->
    @getModel().setCursorBufferPosition opts, autoscroll: true

  markBufferPosition: (opts) ->
    @getModel().markBufferPosition(opts)

  decorateMarker: (marker, opts) ->
    @getModel().decorateMarker(marker, opts)

  serialize: ->
    uri: @uri
    id: @id
    script: @script

  deserialize: (state) ->
    return new NonEditableEditorView(state)

  getTitle: ->
    @title or 'NativeScript'

  getUri: ->
    @uri
