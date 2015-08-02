fs = require 'fs'
path = require 'path'

class FileFinderUtil

  @createPath: (dir, fileName) ->
    isWin = /^win/.test(process.platform)
    if isWin
      return dir + '\\' + fileName
    else
      return dir + '/' + fileName

  findFiles: (regex) ->
    projPaths = atom.project.getPaths()

    foundFiles = projPaths.filter((p) -> p != 'atom://config')
      .map((path) -> return findFilesHelper(path, regex))
      .reduce((results, files) ->
        return results.concat(files)
      , [])

    return foundFiles

  findFilesHelper = (cwd, regex) ->
    dirs = []
    files = []

    for entry in fs.readdirSync(cwd) when entry.indexOf('.') isnt 0
      if regex.test(entry)
        files.push({
          dir: cwd,
          fileName: entry
        })

      else if entry.indexOf('node_modules') is -1
        abs = path.join(cwd, entry)
        if fs.statSync(abs).isDirectory()
          dirs.push abs

    for dir in dirs
      if foundFiles = findFilesHelper(dir, regex)
        files = files.concat(foundFiles)

    return files

module.exports = FileFinderUtil
