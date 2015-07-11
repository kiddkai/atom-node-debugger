{CommandHistory} = require '../../lib/Components/consolepane-utils'

class FakeEditor
  setText: (text) ->
      @text = text

describe 'CommandHistory', ->
  editor = null
  history = null
  beforeEach ->
    editor = new FakeEditor()
    history = new CommandHistory(editor)
  describe '.saveIfNew', ->
    it 'saves a command if no previous commands has been saved', ->
      history.saveIfNew('command1')
      expect(editor.text?).toBe(false)
      expect(history.cmdHistory.length).toBe(1)
      expect(history.cmdHistory[0]).toBe('command1')
    it 'saves a sequence of unique commands', ->
      history.saveIfNew('command1')
      history.saveIfNew('command2')
      history.saveIfNew('command3')
      expect(editor.text?).toBe(false)
      expect(history.cmdHistory.length).toBe(3)
      expect(history.cmdHistory[0]).toBe('command1')
      expect(history.cmdHistory[1]).toBe('command2')
      expect(history.cmdHistory[2]).toBe('command3')
    it 'does not save a command that matches the current', ->
      history.saveIfNew('command1')
      history.saveIfNew('command2')
      history.saveIfNew('command3')
      expect(history.cmdHistory.length).toBe(3)
      history.moveUp()
      expect(editor.text).toBe('command3')
      history.saveIfNew(editor.text)
      expect(history.cmdHistory.length).toBe(3)
      expect(history.cmdHistory[0]).toBe('command1')
      expect(history.cmdHistory[1]).toBe('command2')
      expect(history.cmdHistory[2]).toBe('command3')
    it 'saves a new command at the end even when traversing history', ->
      history.saveIfNew('command1')
      history.saveIfNew('command2')
      history.saveIfNew('command3')
      expect(history.cmdHistory.length).toBe(3)
      history.moveUp()
      history.moveUp()
      expect(editor.text).toBe('command2')
      editor.text = 'command4'
      history.saveIfNew(editor.text)
      expect(history.cmdHistory.length).toBe(4)
      expect(history.cmdHistory[0]).toBe('command1')
      expect(history.cmdHistory[1]).toBe('command2')
      expect(history.cmdHistory[2]).toBe('command3')
      expect(history.cmdHistory[3]).toBe('command4')
  describe '.moveUp', ->
    it 'has no effect if no previous commands has been saved', ->
      history.moveUp()
      expect(editor.text?).toBe(false)
    it 'moves to last command when first called', ->
      history.saveIfNew('command1')
      history.saveIfNew('command2')
      history.saveIfNew('command3')
      history.moveUp()
      expect(editor.text).toBe('command3')
    it 'moves to previous command when called repeatedly', ->
      history.saveIfNew('command1')
      history.saveIfNew('command2')
      history.saveIfNew('command3')
      history.moveUp()
      history.moveUp()
      expect(editor.text).toBe('command2')
    it 'has no effect if already at first command', ->
      history.saveIfNew('command1')
      history.saveIfNew('command2')
      history.saveIfNew('command3')
      history.moveUp()
      history.moveUp()
      history.moveUp()
      expect(editor.text).toBe('command1')
      history.moveUp()
      expect(editor.text).toBe('command1')
    it 'resumes history traversal even if the editor text is changed manually', ->
      history.saveIfNew('command1')
      history.saveIfNew('command2')
      history.saveIfNew('command3')
      history.moveUp()
      expect(editor.text).toBe('command3')
      editor.text = 'some other text'
      history.moveUp()
      expect(editor.text).toBe('command2')
  describe '.moveDown', ->
    it 'has no effect if no previous commands has been saved', ->
      history.moveDown()
      expect(editor.text?).toBe(false)
    it 'has no effect if a command was saved and history traversal is not started', ->
      history.saveIfNew('command1')
      history.saveIfNew('command2')
      history.saveIfNew('command3')
      history.moveDown()
      expect(editor.text?).toBe(false)
    it 'moves to the next command when called during a history traversal', ->
      history.saveIfNew('command1')
      history.saveIfNew('command2')
      history.saveIfNew('command3')
      history.moveUp()
      history.moveUp()
      expect(editor.text).toBe('command2')
      history.moveDown()
      expect(editor.text).toBe('command3')
    it 'has no effect when already at the last command', ->
      history.saveIfNew('command1')
      history.saveIfNew('command2')
      history.saveIfNew('command3')
      history.moveUp()
      history.moveUp()
      expect(editor.text).toBe('command2')
      history.moveDown()
      expect(editor.text).toBe('command3')
      history.moveDown()
      expect(editor.text).toBe('command3')
