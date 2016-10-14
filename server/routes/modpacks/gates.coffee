router = require('express').Router()
solder = require('../../controllers/solderAPI')
ftp = require('../../controllers/serverFiles')

### GET home page. ###
router.get '/', (req, res) ->
  res.render 'modpacks/gates/main',
    title: "GATES Modpack - Saturn Server Network"

router.get '/changelog', (req, res) ->
  res.render 'modpacks/gates/changelog',
    title: "GATES Changelog - Saturn Server Network"

router.get '/mod_list', (req, res) ->
  res.send(solder.getFullModList('gates'))

router.get '/serverfiles', (req, res) ->
  ftp.getServerFiles 'gates', (err, serverFilesList) ->
    res.send([err, serverFilesList])

module.exports = router