request = require('request')
fs = require('fs')
sortObj = require('sort-object')
sort = require('alphanum-sort')

exports.getChangelog = (modpack) ->
  try
    changelogFile = fs.readFileSync("./cache/changelog_#{modpack}.json", 'utf-8')
    changelog = JSON.parse(changelogFile)
    return changelog
  catch e
    logger.error(e)
    return null

exports.createChangelog = (modpack, callback) ->
  require('mkdirp').sync './cache/', (err) ->
    return logger.info('creating ./cache/')
  changelog = {
    time: 0
    latestVersion: ''
    changelog: {}
  }

  link = 'https://solder.saturnserver.org/index.php/api/'
  modpackLink = "#{link}modpack/#{modpack}"
  modsLink = "#{link}mod/"
  await request(modpackLink, defer(err, resultModpack))
  data = JSON.parse(resultModpack['body'])
  prettyName = data['display_name']
  changelog.latestVersion = data['latest']
  builds = sort(data['builds'])
  lastBuildMods = {}
  buildNr = 1
  await request(modsLink, defer(err, resultMods))
  modData = JSON.parse(resultMods['body'])
  changelogData = {}
  for build in builds
    added = {}
    changed = {}
    removed = []
    await request("#{modpackLink}/#{build}", defer(err, resultBuild))
    buildData = JSON.parse(resultBuild['body'])
    mcVersion = buildData['minecraft']
    versionString = "#{mcVersion}_"
    thisBuildMods = {}
    for mod in buildData['mods']
      selector = modData['mods'][mod['name']]
      thisBuildMods[selector] = []
      thisBuildMods[selector]['version'] = mod['version'].replace(versionString, '')
    thisBuildMods = sortObj(thisBuildMods)
    if buildNr is 1
      for mod of thisBuildMods
        added[mod] = thisBuildMods[mod]['version']
    else
      for mod of thisBuildMods
        if mod not of lastBuildMods
          added[mod] = thisBuildMods[mod]['version']
      for mod of thisBuildMods
        if (mod of lastBuildMods) and (lastBuildMods[mod]['version'] isnt thisBuildMods[mod]['version'])
          changed[mod] = thisBuildMods[mod]['version']
      for mod of lastBuildMods
        if mod not of thisBuildMods
          removed.push(mod)
    lastBuildMods = thisBuildMods
    buildNr++
    changelogData[build] = {
      added: added
      changed: changed
      removed: removed
    }

  changelog.time = new Date().getTime()
  changelog.builds = builds.reverse()
  changelog.changelog = changelogData
  fs.writeFileSync("./cache/changelog_#{modpack}.json", JSON.stringify(changelog))
  logger.debug("Successfully fetched changelog for #{prettyName}.")
  return callback()
