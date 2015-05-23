NodeDebugger = require '../lib/node-debugger'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.
describe "NodeDebugger", ->
  activationPromise = null
  workspaceElement = null

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('node-debugger')

  describe "when the node-debugger:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(workspaceElement.querySelector('.node-debugger')).not.toExist()
      atom.commands.dispatch workspaceElement, 'node-debugger:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        atom.commands.dispatch workspaceElement, 'node-debugger:toggle'
        expect(workspaceElement.querySelector('.node-debugger')).not.toExist()
