path = require 'path'
fs = require 'fs'
findit = require('findit')
{$$, SelectListView} = require 'atom-space-pen-views'

module.exports =
class ProjectFinderView extends SelectListView
  initialize: () ->
    super
    @addClass('project-finder')

  toggle: ->
    if @panel?.isVisible()
      @hide()
    else
      @show()

  show: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()

    @setLoading 'loading...'
    @findProjects (projects) =>
      @setItems(projects)
      @focusFilterEditor()

  hide: ->
    @panel?.hide()

  cancelled: ->
    @hide()

  confirmed: (project) ->
    @openProject project
    @cancel()

  getFilterKey: ->
    'shortPath'

  viewForItem: (project) ->
    $$ -> @li project.shortPath

  findProjects: (fn) ->
    projects = []
    rootPath = atom.config.get('project-finder.rootPath')
    targetDirs = atom.config.get('project-finder.targetDirs')
    finder = findit(rootPath)

    finder.on 'directory', (dir, stat, stop) =>
      isProjectRoot = targetDirs
        .map (d) -> path.join(dir, d)
        .some (p) -> fs.existsSync(p)

      if isProjectRoot
        projects.push({
          fullPath: dir
          shortPath: dir.replace("#{rootPath}#{path.sep}", '')
        })
        stop()

    finder.on 'end', =>
      fn(projects)

  openProject: (project) ->
    atom.open({ pathsToOpen: [project.fullPath] })
