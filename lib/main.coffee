{CompositeDisposable} = require 'atom'

GruntPane = require './views/grunt-pane'

module.exports =
  activate: (state) ->
    @subscriptions = new CompositeDisposable()
    @gruntPanes = []

    packageFound = atom.packages.getAvailablePackageNames()
      .indexOf('bottom-dock') != -1

    unless packageFound
      atom.notifications.addError 'Could not find Bottom-Dock',
        detail: 'Grunt-Manager: The bottom-dock package is a dependency. \n
        Learn more about bottom-dock here: https://atom.io/packages/bottom-dock'
        dismissable: true

    @subscriptions.add atom.commands.add 'atom-workspace',
      'grunt-manager:add': => @add()

  consumeBottomDock: (@bottomDock) ->
    @add true

  add: (isInitial) ->
    return unless @bottomDock

    newPane = new GruntPane()
    @gruntPanes.push newPane

    @bottomDock.addPane newPane, 'Grunt', isInitial

  deactivate: ->
    @subscriptions.dispose()
    @bottomDock.deletePane pane.getId() for pane in @gruntPanes
