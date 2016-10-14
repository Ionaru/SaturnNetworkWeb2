router = require('express').Router()
solder = require('../../controllers/solderAPI')
ftp = require('../../controllers/serverFiles')

### GET home page. ###
router.get '/', (req, res) ->
  res.render 'modpacks/technolution/main',
    title: "Technolution Advanced Modpack - Saturn Server Network"

router.get '/changelog', (req, res) ->
  res.render 'modpacks/technolution/changelog',
    title: "Technolution Advanced Changelog - Saturn Server Network"

router.get '/mod_list', (req, res) ->
  res.send(solder.getFullModList('technolution'))

router.get '/serverfiles', (req, res) ->
  ftp.getServerFiles 'technolution', (err, serverFilesList) ->
    res.send([err, serverFilesList])

module.exports = router