{View, $} = require 'space-pen'
{Emitter, CompositeDisposable} = require 'atom'
FileFinderUtil = require '../file-finder-util'
gruntfileRunner = require '../gruntfile-runner'
Converter = require 'ansi-to-html'
{Toolbar} = require 'atom-bottom-dock'

class OutputView extends View
  @content: ->
    @div class: 'output-view', style: "display:flex;", =>
      @div class: 'content-container', =>
        @div outlet: 'taskContainer', class: 'task-container', =>
          @div outlet: 'taskListContainer', class: 'task-list-container', =>
            @ul outlet: 'taskList'
          @div outlet: 'customTaskContainer', class: 'custom-task-container', =>
            @span outlet: 'customTaskLabel', class: 'inline-block', 'Custom Task:'
        @div outlet: 'outputContainer', class: 'output-container'

  initialize: ->
    @emitter = new Emitter()
    @converter = new Converter()
    @subscriptions = new CompositeDisposable()

    @setupCustomTaskInput()

  setupTaskList: (tasks) ->
    for task in @tasks.sort()
      textElement = $("<span class='icon icon-zap'>#{task}</span>")
      listItem = $('<li>')

      do (task) => textElement.on 'click', =>
        @runTask task

      listItem.append textElement
      @taskList.append listItem

  setupCustomTaskInput: ->
    customTaskInput = document.createElement 'atom-text-editor'
    customTaskInput.setAttribute 'mini', ''
    customTaskInput.getModel().setPlaceholderText 'Press Enter to run'

    # Run if user presses enter
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

  setupGruntfileRunner: (gruntfile) ->
    @gruntfileRunner = new gruntfileRunner gruntfile.path

  runTask: (task) ->
    @gruntfileRunner?.runGrunt task, @onOutput, @onError, @onExit

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

  stop: ->
    if @gruntfileRunner
      @gruntfileRunner.destroy()
      @writeOutput('Task Stopped', 'text-info')

  clear: ->
    @outputContainer.empty()

  refresh: (gruntfile) ->
    @destroy()
    @outputContainer.empty()
    @taskList.empty()

    unless gruntfile
      @gruntfile = null
      return

    @gruntfile = gruntfile
    @setupGruntfileRunner @gruntfile
    @addGruntTasks()

  destroy: ->
    @gruntfileRunner?.destroy()
    @gruntfileRunner = null
    @subscriptions?.dispose()

module.exports = OutputView
