hg = require 'mercury'
{h} = hg
Promise = require 'bluebird'

log = (msg) -> #console.log(msg)

TreeView = (title, loadChildren, { handlers, data, isRoot } = {}) ->
  log "TreeView constructor. title=#{title}, isRoot=#{isRoot}"
  return hg.state({
      isRoot: hg.value(isRoot)
      title: hg.value(title)
      items: hg.array([])
      isOpen: hg.value(false)
      loading: hg.value(false)
      loaded: hg.value(false)
      data: data
      channels: {
        click:
          (state) ->
            TreeView.toggle(state)
            handlers?.click?(state.data)
      }
      functors: {
        render: TreeView.defaultRender
        loadChildren: loadChildren
      }
    })

TreeView.toggle = (state) ->
  log "TreeView.toggle #{state.isOpen()} item count=#{state.items().length} loaded=#{state.loaded()}, loading=#{state.loading()}"
  state.isOpen.set(!state.isOpen())
  return if state.loading() or state.loaded()
  TreeView.populate(state)

TreeView.reset = (state) ->
  log "TreeView.reset"
  return unless state.loaded()
  state.items.set([])
  state.isOpen.set(false)
  state.loaded.set(false)
  state.loading.set(false)
  log "TreeView.reset: done"

TreeView.populate = (state) ->
  log "TreeView.populate"
  state.loading.set(true)
  state.functors.loadChildren()
  .then (children) ->
    log "TreeView.populate: children loaded. count=#{children.length})"
    state.items.set(children)
  .then () ->
    log "TreeView.populate: all done"
    state.loaded.set(true)
    state.loading.set(false)
  .catch (e) ->
    log("TreeView.populate:error!!!" + JSON.stringify(e))
    state.loaded.set(false)
    state.loading.set(false)

TreeView.render = (state) ->
  return state?.functors?.render?(state)

TreeView.defaultRender = (state) ->
  log "TreeView.render"
  title = state.title?(state) ? state.title
  result = h('li.list-nested-item', {
        className: if state.isOpen then '' else 'collapsed'
      }, [
        h('div.header.list-item' + (if state.isRoot then '.heading' else ''), { 'ev-click': hg.send state.channels.click }, [title]),
        h('ul.entries.list-tree', {}, state.items.map(TreeView.render))
      ])

  result = h('div.debugger-vertical-pane.inset-panel', {}, [
      h('ul.list-tree.has-collapsable-children', {}, [result])
    ]) if state.isRoot
  return result

TreeViewItem = (value, { handlers, data } = {}) -> hg.state({
    value: hg.value(value)
    data: data
    channels: {
      click:
        (state) -> handlers?.click?(state.data)
    }
    functors: {
      render: TreeViewItem.render
    }
  })

TreeViewItem.render = (state) ->
  h('li.list-item.entry', { 'ev-click': hg.send state.channels.click }, [state.value?(state) ? state.value])

class TreeViewUtils
  @createFileRefHeader: (fullPath, line) ->
        return (state) -> h("div", {
            title: fullPath
            style:
              display: 'inline'
          }
          ["#{atom.project.relativizePath(fullPath)[1]} : #{line}"]
        )

exports.TreeView = TreeView
exports.TreeViewItem = TreeViewItem
exports.TreeViewUtils = TreeViewUtils
