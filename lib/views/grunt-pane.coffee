{DockPaneView, Toolbar} = require 'atom-bottom-dock'
{Emitter, CompositeDisposable} = require 'atom'
OutputView = require './output-view'
ControlsView = require './controls-view'
FileFinderUtil = require '../file-finder-util'
{$} = require 'space-pen'

class GruntPane extends DockPaneView
  @content: ->
    @div class: 'grunt-pane', style: 'display:flex;', =>
      @subview 'toolbar', new Toolbar()
      @subview 'outputView', new OutputView()

  initialize: ->
    super()
    @fileFinderUtil = new FileFinderUtil()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()
    @controlsView = new ControlsView()

    @outputView.show()

    @toolbar.addLeftTile item: @controlsView, priority: 0

    @subscriptions.add @controlsView.onDidSelectGruntfile @setGruntfile
    @subscriptions.add @controlsView.onDidClickRefresh @refresh
    @subscriptions.add @controlsView.onDidClickStop @stop
    @subscriptions.add @controlsView.onDidClickClear @clear

    @getGruntfiles()

  getGruntfiles: ->
    gruntfiles = []

    for filePath in @fileFinderUtil.findFiles /^Gruntfile\.[js|coffee]/i
      gruntfiles.push
        path: filePath
        relativePath: FileFinderUtil.getRelativePath filePath

    @controlsView.updateGruntfiles gruntfiles

  setGruntfile: (gruntfile) =>
    @outputView.refresh gruntfile

  refresh: =>
    @outputView.refresh()
    @getGruntfiles()

  stop: =>
    @outputView.stop()

  clear: =>
    @outputView.clear()

  destroy: ->
    @outputView.destroy()
    @subscriptions.dispose()
    @remove()

module.exports = GruntPane
