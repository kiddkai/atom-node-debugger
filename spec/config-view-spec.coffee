{TextEditorView} = require 'atom-space-pen-views'
ConfigView = require '../lib/config-view'

describe 'config view', ->

  configView = null

  beforeEach ->
    atom.workspace = atom.workspace

    spyOn(atom.workspace, 'getActiveTextEditor')
    .andReturn((new TextEditorView(mini: true)).getModel())

    configView = new ConfigView(autoFill: false)

  it 'should be able to start a node process according to the inputs', ->

    spyOn(configView.runner, 'start')

    # set up data
    configView
      .nodePathInput
      .getModel()
      .setText('/bin/node')

    configView
      .appPathInput
      .getModel()
      .setText('/path/to/debug.js')

    configView.startRunning()

    expect(configView.runner.start).toHaveBeenCalledWith({
      nodePath: '/bin/node',
      runPath: '/path/to/debug.js',
      args: ''
    })
