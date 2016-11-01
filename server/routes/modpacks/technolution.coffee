router = require('express').Router()
solder = require('../../controllers/solderAPI')
changelog = require('../../controllers/getChangelog')
ftp = require('../../controllers/serverFiles')

router.get '/', (req, res) ->
  return res.render 'modpacks/technolution/main',
    title: 'Technolution Advanced Modpack - Saturn Server Network'

router.get '/changelog', (req, res) ->
  log = changelog.getChangelog('technolution')
  return res.render 'modpacks/technolution/changelog',
    title: 'Technolution Advanced Changelog - Saturn Server Network'
    changelog: log

router.get '/mod_list', (req, res) ->
  return res.send(solder.getFullModList('technolution'))

router.get '/serverfiles', (req, res) ->
  ftp.getServerFiles 'technolution', (err, serverFilesList) ->
    return res.send([err, serverFilesList])
  return

module.exports = router