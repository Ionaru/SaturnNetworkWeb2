express = require('express')
solder = require('../../controllers/solderAPI')
ftp = require('../../controllers/serverFiles')
router = express.Router()

### GET home page. ###
router.get '/', (req, res) ->
  res.render 'modpacks/gates/main',
    title: "GATES Modpack - Saturn Server Network"

#router.get '/changelog', (req, res) ->
#  res.render 'modpacks/gates/changelog',
#    title: "GATES Changelog - Saturn Server Network"

router.get '/mod_list', (req, res) ->
  solder.getFullModList 'gates', (err, fullModList) ->
    res.send([err, fullModList])

router.get '/serverfiles', (req, res) ->
  ftp.getServerFiles 'gates', (err, serverFilesList) ->
    res.send([err, serverFilesList])

module.exports = router