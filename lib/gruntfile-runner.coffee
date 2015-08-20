FileFinderUtil = require('./file-finder-util')
{BufferedProcess} = require('atom')

class GruntfileRunner
  constructor: (@filePath) ->
    @fileFinderUtil = new FileFinderUtil()

  getGruntTasks: (onOutput, onError, onFinished) ->
    allOutput = ""
    concatOutput = (output) ->
      allOutput = allOutput + output

    onExit = (code) ->
      onOutput(extractTasks(allOutput)) if code == 0
      onFinished code

    @runGrunt '--help', concatOutput, onError, onExit, '--no-color'

  extractTasks = (output) ->
    lines = output.split '\n'
    tasksStart = lines.indexOf('Available tasks') + 1
    tasksEnd = tasksStart + lines.slice(tasksStart).indexOf('')

    tasks = lines.slice(tasksStart, tasksEnd).map (line) ->
      line.trim().split(' ')[0]

    tasks

  runGrunt: (task, stdout, stderr, exit, extraArgs) ->
    @process.kill() if @process
    @process = null

    args = ['--gruntfile', @filePath]

    if task
      for arg in task.split ' '
        args.push arg

    if extraArgs
      for arg in extraArgs.split ' '
        args.push arg

    process.env.PATH = switch process.platform
      when 'win32' then process.env.PATH
      else "#{process.env.PATH}:/usr/local/bin"

    options =
      env: process.env

    @process = new BufferedProcess
      command: 'grunt'
      args: args
      options: options
      stdout: stdout
      stderr: stderr
      exit: exit

  destroy: ->
    @process.kill() if @process
    @process = null

module.exports = GruntfileRunner
