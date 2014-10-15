{EditorView} = require 'atom'
BreakpointGutterView = require '../lib/breakpoint-gutter-view'
debuggerContext = require '../lib/debugger'

describe 'Set a gutter according to the breakpoints', ->

  editorView = null
  editor = null
  gutter = null
  breakpoints = null

  beforeEach ->
    editorView = new EditorView(mini: true)
    editorView.gutter =
      addClassToLine: jasmine.createSpy()

    gutter = editorView.gutter
    editor = editorView.getEditor()

    breakpoints = debuggerContext.breakpoints


  it 'should be able to add the class to gutter', ->
    spyOn(debuggerContext.breakpoints, 'getBreakpoints').andReturn([
      { scriptName: '/path/to/file1.js', line: 1 },
      { scriptName: '/path/to/file2.js', line: 10 }
    ])
    spyOn(editor, 'getPath').andReturn('/path/to/file2.js')
    breakpointGutterView = new BreakpointGutterView(editorView)
    expect(gutter.addClassToLine).toHaveBeenCalled()


  it 'should be able to add the breakpoint for the file which path is the same', ->
    spyOn(debuggerContext.breakpoints, 'getBreakpoints').andReturn([
      { scriptName: '/path/to/file1.js', line: 1 },
      { scriptName: '/path/to/file2.js', line: 10 }
    ])
    spyOn(editor, 'getPath').andReturn('/path/to/file2.js')
    breakpointGutterView = new BreakpointGutterView(editorView)
    expect(gutter.addClassToLine).toHaveBeenCalledWith(11, 'gutter-breakpoint')

  it 'should be able to add the classes to line when editor changed path', ->
    spyOn(debuggerContext.breakpoints, 'getBreakpoints').andReturn([
      { scriptName: '/path/to/file1.js', line: 1 },
      { scriptName: '/path/to/file2.js', line: 10 }
    ])
    spyOn(editor, 'getPath').andReturn('/path/to/file1.js')
    breakpointGutterView = new BreakpointGutterView(editorView)
    editorView.trigger 'editor:path-changed'
    expect(gutter.addClassToLine).toHaveBeenCalledWith(2, 'gutter-breakpoint')

  it 'should be able to update the classes to line when breakpoints changed', ->
    breakpointGutterView = new BreakpointGutterView(editorView)
    spyOn(breakpoints, 'getBreakpoints').andReturn([{
        scriptName: '/path/to/file2.js',
        line: 12
    }])
    spyOn(editor, 'getPath').andReturn('/path/to/file2.js')
    breakpoints.emit 'change'
    expect(gutter.addClassToLine).toHaveBeenCalledWith(13, 'gutter-breakpoint');
