path = require 'path'
{$} = require 'atom-space-pen-views'

describe 'ProjectFinder', ->
  fixtureDir = path.join(__dirname, 'fixture')
  [activationPromise, projectFinderView, workspaceElement] = []

  find = (selector) ->
    $(workspaceElement).find(selector)

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)

    atom.config.set('project-finder.rootPath', fixtureDir)
    atom.config.set('project-finder.targetDirs', ['.git', '.svn'])

    waitsForPromise -> atom.packages.activatePackage('project-finder').then ({mainModule}) ->
      projectFinderView = mainModule.getView()
      projectFinderView.hide()

  describe 'when the project-finder:toggle event is triggered', ->
    it 'shows the view containing the list of projects', ->
      expect(find '.project-finder').not.toExist()
      atom.commands.dispatch workspaceElement, 'project-finder:toggle'
      expect(find '.project-finder').toExist()
      waitsFor -> find('.project-finder li').length is 2
      runs ->
        projects = find('.project-finder li').toArray().map (el) -> $(el).text()
        expect(projects).toContain 'foo'
        expect(projects).toContain 'bar/sub'

  describe "when project is selected", ->
    it 'opens the project', ->
      spyOn(atom, "open")
      atom.commands.dispatch workspaceElement, 'project-finder:toggle'
      list = []
      waitsFor ->
        list = find('.project-finder li')
        list.length is 2
      runs ->
        atom.commands.dispatch projectFinderView.element, 'core:confirm'
        expect(atom.open.callCount).toBe 1
        expect(atom.open.argsForCall[0][0]).toEqual pathsToOpen: ["#{fixtureDir}/#{list.first().text()}"]
