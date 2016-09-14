express = require('express')
router = express.Router()

### GET users listing. ###

router.get '/', (req, res, next) ->
  res.render 'users'

module.exports = router