{View, $} = require 'space-pen'
{Emitter} = require 'atom'
FileFinderUtil = require '../file-finder-util'
{Toolbar} = require 'atom-bottom-dock'

class GruntView extends View
  @content: ->
    @div class: 'grunt-view', style: 'display:flex;', =>
      @div outlet: 'fileContainer', class: 'file-container',  =>
        @ul outlet: 'fileList'

  initialize: ->
    @emitter = new Emitter()
    @fileFinderUtil = new FileFinderUtil()

    @createGruntfileList()

  createGruntfileList: ->
    @fileList.empty()
    for filePath in @fileFinderUtil.findFiles /^Gruntfile\.[js|coffee]/i
      gruntfile =
        path: filePath
        relativePath: FileFinderUtil.getRelativePath filePath

      listItem = $("<li><span class='icon icon-file-text'>#{gruntfile.relativePath}</span></li>")

      do (gruntfile, @emitter) ->
        listItem.first().on 'click', ->
          emitter.emit 'gruntfile:selected', gruntfile
      @fileList.append(listItem)

  onDidClickGruntfile: (callback) ->
    return @emitter.on 'gruntfile:selected', callback

  refresh: ->
    @createGruntfileList()

  destroy: ->

module.exports = GruntView
