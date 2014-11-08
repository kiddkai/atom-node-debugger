GutterState = require './state'

module.exports = 
class BreakpointGutter

  constructor: ->
    @state = new GutterState()
    @state.on 'change', @update
    @decorations = []
    @state.update()

  update: =>
    @clean()
    self = this
    gutters = @state.gutters
    atom
      .workspace
      .eachEditor (editor) ->
        gutters
          .filter (g) -> g.path is editor.getPath()
          .forEach (g) ->
            marker = editor.markBufferPosition([g.line, 0])
            decoration = editor.decorateMarker(marker, {
              type: 'gutter'
              class: 'gutter-breakpoint'
            })

            self.decorations.push(decoration)

  clean: =>
    @decorations
      .map (d) -> d.getMarker()
      .forEach (m) -> m.destroy()

    @decorations = []

  destroy: ->
    @clean()
    @state.destroy()
    @state.removeListener 'change', @update
