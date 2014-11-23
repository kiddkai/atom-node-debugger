{Workspace, TextEditorView} = require 'atom'
ConfigView = require '../lib/config-view'

describe 'config view', ->

  configView = null

  beforeEach ->
    atom.workspace = new Workspace
    spyOn(atom.workspace, 'getActiveEditor').andReturn((new TextEditorView(mini: true)).getEditor())

    configView = new ConfigView(autoFill: false)

  it 'should be able to create start a node process according to the inputs', ->

    spyOn(configView.runner, 'start')

    # set up data
    configView
      .nodePathInput
      .getEditor()
      .setText('/bin/node')

    configView
      .appPathInput
      .getEditor()
      .setText('/path/to/debug.js')

    configView.startRunning()

    expect(configView.runner.start).toHaveBeenCalledWith({
      nodePath: '/bin/node',
      runPath: '/path/to/debug.js',
      args: ''
    });
