{View, $} = require 'space-pen'
{Emitter, CompositeDisposable} = require 'atom'
FileFinderUtil = require '../file-finder-util'
gruntfileRunner = require '../gruntfile-runner'
Converter = require 'ansi-to-html'

class OutputView extends View
  @content: ->
    @div class: 'output-view', style: "display:flex;", =>
      @div outlet: 'taskContainer', class: 'task-container', =>
        @div outlet: 'taskListContainer', class: 'task-list-container', =>
          @ul outlet: 'taskList'
        @div outlet: 'customTaskContainer', class: 'custom-task-container', =>
          @span outlet: 'customTaskLabel', class: 'inline-block', 'Custom Task:'
        @div outlet: 'controlContainer', class: 'control-container', =>
          @button outlet: 'backButton', class: 'btn', click: 'onBackClicked', 'Back'
          @button outlet: 'stopButton', class: 'btn', click: 'onStopClicked', 'Stop'
      @div outlet: 'outputContainer', class: 'output-container'

  initialize: ->
    @emitter = new Emitter()
    @converter = new Converter()
    @subscriptions = new CompositeDisposable()

    @setupCustomTaskInput()

  setupTaskList: (tasks) ->
    for task in @tasks.sort()
      listItem = $("<li><span class='icon icon-zap'>#{task}</span></li>")

      do (task) => listItem.first().on 'click', =>
        @runTask task

      @taskList.append listItem

  setupCustomTaskInput: ->
    customTaskInput = document.createElement 'atom-text-editor'
    customTaskInput.setAttribute 'mini', ''
    customTaskInput.getModel().setPlaceholderText 'Press Enter to run'

    #Run if user presses enter
    customTaskInput.addEventListener 'keyup', (e) =>
      @runTask(customTaskInput.getModel().getText()) if e.keyCode == 13

    @customTaskContainer.append customTaskInput

  addGruntTasks: ->
    @tasks = []
    output = "fetching tasks for #{@gruntfile.relativePath}"
    @writeOutput output, 'text-info'

    @taskList.empty()

    onTaskOutput = (tasks) =>
      @tasks = (task for task in tasks when task.length)

    onTaskExit = (code) =>
      if code is 0
        @setupTaskList @tasks
        @writeOutput "#{@tasks.length} tasks found", "text-info"
      else
        @onExit code

    @gruntfileRunner.getGruntTasks onTaskOutput, @onError, onTaskExit

  onStopClicked: ->
    if @gruntfileRunner
      @gruntfileRunner.destroy()
      @writeOutput('Task Stopped', 'text-info')

  onBackClicked: ->
    @gulpfile = null
    @emitter.emit 'backButton:clicked'

  onDidClickBack: (callback) ->
    @emitter.on 'backButton:clicked', callback

  setupGruntfileRunner: (gruntfile) ->
    @gruntfileRunner = new gruntfileRunner gruntfile.path

  runTask: (task) ->
    @gruntfileRunner.runGrunt task, @onOutput, @onError, @onExit

  writeOutput: (line, klass) ->
    return unless line?.length

    el = $('<pre>')
    el.append line
    if klass
      el.addClass klass
    @outputContainer.append el
    @outputContainer.scrollToBottom()

  onOutput: (output) =>
    for line in output.split '\n'
      @writeOutput(@converter.toHtml(line))

  onError: (output) =>
    for line in output.split '\n'
      @writeOutput(@converter.toHtml(line), 'text-error')

  onExit: (code) =>
    @writeOutput("Exited with code #{code}",
      "#{if code then 'text-error' else 'text-success'}")

  refresh: (gruntfile) ->
    @destroy()
    @outputContainer.empty()
    @taskList.empty()

    @gruntfile = gruntfile if gruntfile

    return unless @gruntfile

    @setupGruntfileRunner @gruntfile
    @addGruntTasks()

  destroy: ->
    @gruntfileRunner?.destroy()
    @gruntfileRunner = null
    @subscriptions?.dispose()

module.exports = OutputView
