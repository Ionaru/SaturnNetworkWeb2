request = require('request')
fs = require('fs')
sortObj = require('sort-object')
sort = require('alphanum-sort')

exports.getChangelog = (modpack) ->
  try
    changelogFile = fs.readFileSync("./cache/changelog_#{modpack}.json", "utf-8")
    changelog = JSON.parse(changelogFile)
    return changelog
  catch e
    logger.error(e)
    return null

exports.createChangelog = (modpack, callback) ->
  require('mkdirp').sync "./cache/", (err) ->
    logger.info("creating ./cache/")
  changelog = {
    time: 0
    latestVersion: ""
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
  changelogDisplay = ""
  await request(modsLink, defer(err, resultMods))
  modData = JSON.parse(resultMods['body'])
  dropdownDisplay = ""
  topDisplay = "<div class=\"container changelog\">
  <h2>#{prettyName} Changelog</h2>
    <div class=\"dropdown\">
        <button class=\"btn btn-default dropdown-toggle btn-primary btn-sm\" type=\"button\" id=\"dropdownMenu1\"
                data-toggle=\"dropdown\" aria-haspopup=\"true\" aria-expanded=\"true\">
            Choose a Version
            <span class=\"caret\"></span>
        </button>
        <ul class=\"dropdown-menu\" aria-labelledby=\"dropdownMenu1\">"
  for build in builds
    dropdownDisplay = "<li><a href=\"##{build}\">#{build}</a></li>" + dropdownDisplay
  topDisplay += dropdownDisplay
  topDisplay += '</ul></div><br>
        <div class="text-right">
            <a class="btn btn-success btn-sm btn-pad disabled mod-label">Added Mod
                <span class="badge">Version</span>
            </a>
            <a class="btn btn-primary btn-sm btn-pad disabled mod-label">Changed Mod
                <span class="badge">New Version</span>
            </a>
            <a class="btn btn-danger btn-sm btn-pad disabled mod-label">Removed Mod</a>
        </div>'
  changelogData = {}
  for build in builds
    versionDisplay = "<hr><div><h3>#{build}</h3><a class=\"anchor\" id=\"#{build}\"></a>"
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
      thisBuildMods[selector]['version'] = mod['version'].replace(versionString, "")
    thisBuildMods = sortObj(thisBuildMods)
    if buildNr is 1
      for mod of thisBuildMods
        added[mod] = thisBuildMods[mod]['version']
        versionDisplay += "<a class=\"btn btn-success btn-sm btn-pad disabled mod-label\">#{mod}
                            <span class=\"badge\">#{thisBuildMods[mod]['version']}</span></a> "
    else
      for mod of thisBuildMods
        if mod not of lastBuildMods
          added[mod] = thisBuildMods[mod]['version']
          versionDisplay += "<a class=\"btn btn-success btn-sm btn-pad disabled mod-label\">#{mod}
                              <span class=\"badge\">#{thisBuildMods[mod]['version']}</span></a> "
      versionDisplay += "<br>"
      for mod of thisBuildMods
        if (mod of lastBuildMods) and (lastBuildMods[mod]['version'] isnt thisBuildMods[mod]['version'])
          changed[mod] = thisBuildMods[mod]['version']
          versionDisplay += "<a class=\"btn btn-primary btn-sm btn-pad disabled mod-label\">#{mod}
                              <span class=\"badge\">#{thisBuildMods[mod]['version']}</span></a> "
      versionDisplay += "<br>"
      for mod of lastBuildMods
        if mod not of thisBuildMods
          removed.push(mod)
          versionDisplay += "<a class=\"btn btn-danger btn-sm btn-pad disabled mod-label\">#{mod}</a> "
    versionDisplay += "<br><br><a href=\"#\" class=\"btn btn-primary btn-sm\">Back to Top
                        <i class=\"fa fa-caret-up\"></i></a></div>"
    lastBuildMods = thisBuildMods
    buildNr++
    changelogDisplay = versionDisplay + changelogDisplay
    changelogData[build] = {
      added: added
      changed: changed
      removed: removed
    }

  changelogDisplay = topDisplay + changelogDisplay
  changelogDisplay += "</div>"
  changelog.time = new Date().getTime()
  changelog.changelog = changelogData
  fs.writeFileSync("./cache/changelog_#{modpack}.json", JSON.stringify(changelog))
  fs.writeFileSync("./client/views/modpacks/#{modpack}/changelog.hbs", changelogDisplay)
  logger.debug("Successfully fetched changelog for #{prettyName}.")
  callback()
