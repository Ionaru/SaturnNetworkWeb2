request = require 'request'
fs = require 'fs'
sortObj = require 'sort-object'

exports.getFullModList = (modpack) ->
  try
    savedFile = fs.readFileSync("./cache/fullModList_#{modpack}.json")
    fullModList = JSON.parse(savedFile)
    return fullModList
  catch e
    logger.error(e)
    return null

exports.writeFullModList = (modpack, callback) ->
  require('mkdirp').sync('./cache/')
  modpackName = modpack
  fullModList = {
    time: 0
    minecraftVersion: '',
    modpackVersion: '',
    mods: {}
  }
  apiLink = solderConfig['api_link']
  modpackLink = apiLink + 'modpack/' + modpack
  await request(modpackLink, defer(err, result))
  if not err
    modpack = JSON.parse(result['body'])
    await request(modpackLink + '/' + modpack['latest'], defer(err, result))
    modpackVersion = JSON.parse(result['body'])
    minecraftVersion = modpackVersion['minecraft']
    versionPrefix = minecraftVersion + '_'
    fullModList.minecraftVersion = minecraftVersion
    fullModList.modpackVersion = modpack['latest']
    fullModList.mods = {}
    for mod in modpackVersion['mods']
      fullModList.mods[mod['name']] =
        version: mod['version'].replace(versionPrefix, '')
    modsKeys = Object.keys(fullModList.mods)
    index = 0
    for mod in modsKeys
      modSelect = modsKeys[index]
      await request(apiLink + 'mod/' + modSelect, defer(err, result))
      if not err
        modInfo = JSON.parse(result['body'])
        fullModList.mods[modSelect]['pretty_name'] = modInfo['pretty_name']
        fullModList.mods[modSelect]['author'] = modInfo['author']
        fullModList.mods[modSelect]['description'] = modInfo['description']
        fullModList.mods[modSelect]['link'] = modInfo['link']
        index++
    fullModList.time = new Date().getTime()
    fullModList2 = {
      time: new Date().getTime()
      minecraftVersion: minecraftVersion
      modpackVersion: modpack['latest']
      mods: {}
    }
    for mod of fullModList.mods
      fullModList2.mods[fullModList.mods[mod]['pretty_name']] = fullModList.mods[mod]
      delete fullModList.mods[mod]['pretty_name']
    fullModList2.mods = sortObj(fullModList2.mods)
    fs.writeFileSync("./cache/fullModList_#{modpackName}.json", JSON.stringify(fullModList2))
    logger.debug "Successfully fetched modpack data for #{modpack['display_name']}."
    return callback()
  else
    logger.error(err)
    return callback()
