express = require('express')
router = express.Router()

### GET home page. ###

router.get '/', (req, res, next) ->
  res.json({ message: 'Hooray! welcome to our api!' });

router.route('/bears').post((req, res) ->
  bear = new Bear
  # create a new instance of the Bear model
  bear.name = req.body.name
  # set the bears name (comes from the request)
  # save the bear and check for errors
  bear.save (err) ->
    if err
      res.send err
    res.json message: 'Bear created!'
).get (req, res) ->
  Bear.find (err, bears) ->
    if err
      res.send err
    res.json bears

module.exports = router
