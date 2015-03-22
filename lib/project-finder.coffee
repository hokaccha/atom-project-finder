module.exports =
  config:
    rootPath:
      title: 'Root path'
      description:  'Path to directory containing project directories. (Default is core.projectHome)'
      type: 'string'
      default: atom.config.get('core.projectHome')
    targetDirs:
      title: 'Target directories'
      description: 'Directory name that exists in project root directory.'
      type: 'array'
      default: ['.git', '.hg', '.svn']

  activate: ->
    atom.commands.add 'atom-workspace', 'project-finder:toggle', =>
      @getView().toggle()

  deactivate: ->
    if @projectFinderView?
      @projectFinderView = null

  getView: ->
    unless @projectFinderView?
      ProjectFinderView  = require './project-finder-view'
      @projectFinderView ?= new ProjectFinderView()
    @projectFinderView
