# Track command history for console pane
class CommandHistory
  constructor: (editor) ->
    @editor = editor
    @cmdHistory = []

  saveIfNew: (text) ->
    unless @cmdHistoryIndex? and @cmdHistory[@cmdHistoryIndex] is text
      @cmdHistoryIndex = @cmdHistory.length
      @cmdHistory.push text
    @historyMode = false
  moveUp: ->
    return unless @cmdHistoryIndex?
    if @cmdHistoryIndex > 0 and @historyMode
      @cmdHistoryIndex--
    @editor.setText(@cmdHistory[@cmdHistoryIndex])
    @historyMode = true
  moveDown: ->
    return unless @cmdHistoryIndex?
    return unless @historyMode
    if @cmdHistoryIndex < @cmdHistory.length - 1 and @historyMode
      @cmdHistoryIndex++
    @editor.setText(@cmdHistory[@cmdHistoryIndex])

# Exports
exports.CommandHistory = CommandHistory
