express = require('express')
router = express.Router()
user = require('..//models/user')

### GET home page. ###

router.get '/', (req, res) ->
  res.render 'index'

module.exports = router