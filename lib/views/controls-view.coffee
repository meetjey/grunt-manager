{DockPaneView} = require 'atom-bottom-dock'
{Emitter, CompositeDisposable} = require 'atom'
{$} = require 'space-pen'

class ControlsView extends DockPaneView
  @content: ->
    @div =>
      @span outlet: 'stopButton', class: 'stop-button icon icon-primitive-square', click: 'onStopClicked'
      @span outlet: 'refreshButton', class: 'refresh-button icon icon-sync', click: 'onRefreshClicked'
      @span outlet: 'clearButton', class: 'clear-button icon icon-history', click: 'onClearClicked'
      @select outlet: 'fileSelector'

  initialize: ->
    super()
    @emitter = new Emitter()
    @subscriptions = new CompositeDisposable()
    @fileSelector.change(@onGruntfileSelected)

  updateGruntfiles: (gruntfiles) ->
    @gruntfiles = {}
    @fileSelector.empty()

    for gruntfile in gruntfiles
      @gruntfiles[gruntfile.relativePath] = gruntfile

      @fileSelector.append $("<option>#{gruntfile.relativePath}</option>")

    if gruntfiles.length
      @fileSelector.selectedIndex = 0
      @fileSelector.change()

  onDidClickRefresh: (callback) ->
    @emitter.on 'button:refresh:clicked', callback

  onDidClickStop: (callback) ->
    @emitter.on 'button:stop:clicked', callback

  onDidClickClear: (callback) ->
    @emitter.on 'button:clear:clicked', callback

  onDidSelectGruntfile: (callback) ->
    @emitter.on 'gruntfile:selected', callback

  onRefreshClicked: ->
    @emitter.emit 'button:refresh:clicked'

  onStopClicked: ->
    @emitter.emit 'button:stop:clicked'

  onClearClicked: (callback) ->
    @emitter.emit 'button:clear:clicked'

  onGruntfileSelected: (e) =>
    @emitter.emit 'gruntfile:selected', @gruntfiles[e.target.value]

module.exports = ControlsView
