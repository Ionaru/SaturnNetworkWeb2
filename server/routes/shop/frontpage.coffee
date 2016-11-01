router = require('express').Router()

router.get '/', (req, res) ->
  return res.render('shop/frontpage')

module.exports = router
