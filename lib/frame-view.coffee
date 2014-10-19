{View, $, $$} = require 'atom'
debuggerContext = require './debugger'
VariableView = require './variable-view'
q = require 'q'

module.exports =
class FrameView extends View

  @content: (frame) =>
    @ul class:'frames-view list-tree has-collapsable-children', =>

  initialize: ->
    @nthRender = 0
    @frames = debuggerContext.frames
    @frames.refresh().done()
    @frames.on 'change', @render
    @selected = 0
    @on 'click', '.frame-item', @activeSelection
    @on 'click', '.list-nested-item', @toggleCollapsed

  beforeRemove: ->
    @frames.removeListener 'change', @render

  toggleCollapsed: (ev) ->
    ev.stopPropagation()
    $(this).toggleClass('collapsed')

  activeSelection: (ev) =>
    $toActive = $(ev.target).closest('.frame-item')
    @selected = if $toActive.data('index') is @selected then -1 else $toActive.data('index')
    @render()

  render: =>
    @nthRender += 1
    @empty()
    self = this
    frames = @frames.get()
    which = @nthRender

    frames.reduce((promise, frame, index) =>
      return promise.then =>
        return frame.populate().then(=>
          return if which < self.nthRender
          cls = if index is self.selected then 'selected' else 'collapsed'
          self.append $$ ->
            @li class: "frame-item list-nested-item #{cls}", 'data-index': index, =>
              @header class: 'list-item', "#{frame.file} #{frame.line}"
              @ul class: 'frame-body list-tree has-collapsable-children', =>
                @li class: 'list-nested-item', =>
                  @div class: 'list-item', 'local'
                  @ul class: 'frame-locals list-tree', =>
                    for prop in frame.locals
                      @subview 'variable', new VariableView(prop)

                @li class: 'list-nested-item collapsed', =>
                  @div class: 'list-item', 'arguments'
                  @ul class: 'frame-arguments list-tree', =>
                    for prop in frame.args
                      @subview 'variable', new VariableView(prop)

                @li class: 'list-nested-item collapsed', =>
                  @div class: 'list-item', 'this'
                  # @subview 'variable', new VariableView(frame.context)
        )
    , q()).done()
