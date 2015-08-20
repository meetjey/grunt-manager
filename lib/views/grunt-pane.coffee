{DockPaneView} = require 'atom-bottom-dock'
{Emitter, CompositeDisposable} = require 'atom'
GruntView = require './grunt-view'
OutputView = require './output-view'

class GruntPane extends DockPaneView
  @content: ->
    @div class: 'grunt-pane', =>
      @subview 'gruntView', new GruntView()
      @subview 'outputView', new OutputView()

  initialize: ->
    super()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()
    @gruntView.show()
    @outputView.hide()
    @activeView = @gruntView

    @subscriptions.add @gruntView.onDidClickGruntfile @switchToOutputView
    @subscriptions.add @outputView.onDidClickBack @switchToGruntView

  switchToGruntView: =>
    @outputView.hide()
    @gruntView.show()
    @activeView = @gruntView

  switchToOutputView: (gruntfile) =>
    @gruntView.hide()
    @outputView.show()
    @activeView = @outputView
    @outputView.refresh gruntfile

  refresh: ->
    @activeView.refresh()

  destroy: ->
    @outputView.destroy()
    @gruntView.destroy()
    @subscriptions.dispose()
    @remove()

module.exports = GruntPane
