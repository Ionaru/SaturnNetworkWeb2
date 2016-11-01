router = require('express').Router()
solder = require('../../controllers/solderAPI')
changelog = require('../../controllers/getChangelog')
ftp = require('../../controllers/serverFiles')

router.get '/', (req, res) ->
  return res.render 'modpacks/gates/main',
    title: 'GATES Modpack - Saturn Server Network'

router.get '/changelog', (req, res) ->
  log = changelog.getChangelog('gates')
  return res.render 'modpacks/gates/changelog',
    title: 'GATES Changelog - Saturn Server Network'
    changelog: log

router.get '/mod_list', (req, res) ->
  return res.send(solder.getFullModList('gates'))

router.get '/serverfiles', (req, res) ->
  ftp.getServerFiles 'gates', (err, serverFilesList) ->
    return res.send([err, serverFilesList])
  return

module.exports = router