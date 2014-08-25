debuggerContext = require './debugger'

##
# @param {Script} script
# @ref https://code.google.com/p/v8/wiki/DebuggerProtocol#Request_scripts
exports.jumpToFile = (script, line) ->
  uri = script.name

  onDone = (editor) ->
    if editor.getText().length is 0
      editor.setText(script.source)

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
