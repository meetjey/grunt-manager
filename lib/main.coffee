{CompositeDisposable} = require('atom')
{BasicTabButton} = require('atom-bottom-dock')

GruntPane = require('./views/grunt-pane')

module.exports =
  activate: (state) ->
    @subscriptions = new CompositeDisposable()
    @gruntPanes = []

    packageFound = atom.packages.getAvailablePackageNames()
      .indexOf('bottom-dock') != -1

    if not packageFound
      atom.notifications.addError('Could not find Bottom-Dock', {
        detail: 'Grunt-Manager: The bottom-dock package is a dependency. \n
        Learn more about bottom-dock here: https://atom.io/packages/bottom-dock'
        dismissable: true
      })

    @subscriptions.add(atom.commands.add('atom-workspace',
    'grunt-manager:add': => @add())
    )

  consumeBottomDock: (@bottomDock) ->
    @add()

  add: ->
    if @bottomDock
      newPane = new GruntPane()
      @gruntPanes.push(newPane)

      config =
        name: 'Grunt'
        id: newPane.getId()
        active: newPane.isActive()

      newTabButton = new BasicTabButton(config)

      @bottomDock.addPane(newPane, newTabButton)

  deactivate: ->
    @subscriptions.dispose()
    for pane in @gruntPanes
      @bottomDock.deletePane(pane.getId())
