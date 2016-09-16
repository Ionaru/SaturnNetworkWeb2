request = require 'request'
fs = require 'fs'
schedule = require 'node-schedule'

exports.getFullModList = (modpack, done) ->
  try
    savedFile = fs.readFileSync("./cache/fullModList_#{modpack}.json")
    fullModList = JSON.parse(savedFile)
    done null, fullModList
  catch
    done "error", fullModList

exports.checkFullModLists = (modpacks) ->
  for modpack in modpacks
    try
      savedFile = fs.readFileSync("./cache/fullModList_#{modpack}.json")
      fullModList = JSON.parse(savedFile)
      currentTime = new Date().getTime()
      maxExpiry = 15 * 60 * 1000
      if fullModList['time'] >= (currentTime - maxExpiry)
        cacheValid = true
      else
        cacheValid = false
    catch
      cacheValid = false
    if not cacheValid
      writeFullModList modpack, fullModList

writeFullModList = (modpack, old_fullModList=null) ->
  require('mkdirp').sync "./cache/", (err) ->
    console.log "creating ", "./cache/"
  modpackName = modpack
  if old_fullModList
    old_modpackversion = old_fullModList['modpackVersion']
  fullModList = {}
  apiLink = solderConfig['api_link']
  modpackLink = apiLink + "modpack/" + modpack
  request modpackLink, (err, result) ->
    modpack = JSON.parse(result['body'])
    if modpack['latest'] isnt old_modpackversion
      logger.info "Modpack info for #{modpack['display_name']} outdated, refreshing..."
      request modpackLink + "/" + modpack['latest'], (err, result) ->
        modpackVersion = JSON.parse(result['body'])
        minecraftVersion = modpackVersion['minecraft']
        versionPrefix = minecraftVersion + '_'
        fullModList['minecraftVersion'] = minecraftVersion
        fullModList['modpackVersion'] = modpack['latest']
        fullModList['mods'] = {}
        for mod in modpackVersion['mods']
          fullModList['mods'][mod['name']] =
            name: mod['name']
            version: mod['version'].replace(versionPrefix, "")
        modsKeys = Object.keys(fullModList['mods'])
        modsCount = modsKeys.length
        index = 0
        getModInfo = (apiLink) ->
          if index < modsCount
            modSelect = modsKeys[index]
            request apiLink + "mod/" + modSelect, (err, result) ->
              if not err
                modInfo = JSON.parse(result['body'])
                fullModList['mods'][modSelect]['pretty_name'] = modInfo['pretty_name']
                fullModList['mods'][modSelect]['author'] = modInfo['author']
                fullModList['mods'][modSelect]['description'] = modInfo['description']
                fullModList['mods'][modSelect]['link'] = modInfo['link']
                index++
                getModInfo apiLink
          else
            fullModList['time'] = new Date().getTime()
            fs.writeFileSync("./cache/fullModList_#{modpackName}.json", JSON.stringify(fullModList))
            logger.info "Successfully refreshed data for modpack #{modpack['display_name']}."
        getModInfo apiLink
    else
      try
        old_fullModList['time'] = new Date().getTime()
        fs.writeFileSync("./cache/fullModList_#{modpackName}.json", JSON.stringify(old_fullModList))