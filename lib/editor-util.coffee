debuggerContext = require './debugger'
{$} = require 'atom'
_ = require 'lodash'

#
# @param {Script} script
# @ref https://code.google.com/p/v8/wiki/DebuggerProtocol#Request_scripts
exports.jumpToFile = (script, line) ->
  uri = script.name

  onDone = (editor) ->
    if editor.getText().length is 0
      if not script.source?
        debuggerContext.scripts.getById(script.id)
          .then (script) ->
            editor.setText(script.source)
            editor.setCursorBufferPosition([line, 0], autoscroll: true)
          .done()
      else
        editor.setText(script.source)

    editor.setCursorBufferPosition([line, 0], autoscroll: true)
    return editor

  onError = (e)->
    console.error e

  atom
    .workspace
    .open uri,
      initialLine: line
      activatePane: true
      searchAllPanes: true
    .then onDone, onError

#
# get current eidtor focus line
#
# @return {Object} {editor: Editor, line: line, path: path}
#
exports.getFocus = ->
  editor = atom.worspace.getActiveEditor()
  path = editor.getPath()
  line = editor.getCursorBufferPosition().row

  return {
    editor: editor
    line: line
    path: path
  }


exports.colorize = (line) ->
  grammar = atom
              .syntax
              .grammarForScopeName('source.js')

  tokens = grammar.tokenizeLine(line).tokens;

  return tokens
    .map (token) ->
      $ch = $('<span>')
      $ch.text(token.value)
      $ch.addClass -> _.uniq(token.scopes.join(' ').split(/\W/)).join(' ')
      return $ch
