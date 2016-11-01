express = require('express')
app = module.exports = express()

###
  Set the default time a session should be kept
###
app.locals.defaultCookieExpiry = 30 * 24 * 60 * 60 * 1000 # 30 days

###
  Setup Handlebars view engine
###
hbs = require('hbs')
path = require('path')
hbsHelperRegistrator = require('./controllers/hbsHelperRegistrator')
app.set('views', path.join(__dirname, '../client/views'))
app.set('view engine', 'hbs')
hbsHelperRegistrator.registerHelpers(hbs)
hbs.registerPartials(path.join(__dirname, '../client/views/partials'))
logger.info('View engine registered')

###
  Create connection to MySQL Database
###
db = require('./controllers/databaseConnector')
db.connect (err) ->
  if err
    throw err
  else
    logger.info("Connected to '#{dbConfig['db_name']}' MySQL database")
  return

###
  Setup session storage, use the previously created connection to the MySQL Database
###
session = require('express-session')
MySQLStore = require('express-mysql-session')(session)
sessionStore = new MySQLStore({}, db.get())
app.use session({
  key: mainConfig['session_key'],
  secret: mainConfig['session_secret'],
  store: sessionStore,
  resave: true,
  saveUninitialized: true
})
logger.info("MySQL session storage connected to '#{dbConfig['db_name']}'")

###
  Add the favicon
###
favicon = require('serve-favicon')
app.use favicon(path.join(__dirname, '../client/public/', 'favicon.ico'))

###
  Setup bodyparser
###
bodyParser = require('body-parser')
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)

###
  Setup public folders containing stylesheets, images, scripts, etc...
###
app.use express.static(path.join(__dirname, '../client/public'))

###
  Register static information to be used in the application
###
#TODO: Needed?
staticGen = require('./controllers/staticGenerator')
staticGen.generateStaticInformation(app)

###
  All requests should go through the global router first, this way we can keep track of sessions and permissions
  as well as doing things like login, logout and register through a modal on any page
###
app.all '/*', require('./routes/global')

###
  Register the rest of the routes the application should use
###
app.use '/', require('./routes/index')
app.use '/a', require('./routes/administration')
app.use '/gates', require('./routes/modpacks/gates')
app.use '/technolution', require('./routes/modpacks/technolution')
app.use '/profile', require('./routes/profile')
app.use '/user', require('./routes/profile')
app.use '/reset', require('./routes/reset')
if devMode then app.use '/shop', require('./routes/shop/frontpage')

###
  Register a 404 error page
###
app.use (req, res) ->
  err = new Error('Not Found')
  err.status = 404
  res.render('status/404')
  return

###
  Register the error handler for the development environment
###
if devMode
  app.use (err, req, res) ->
    res.status(err.status or 500)
    res.render('error',
      message: err.message
      error: err
    )
    return

###
  Register the error handler for the production environment, no stacktraces should be sent to the client
###
app.use (err, req, res) ->
  res.status(err.status or 500)
  res.render('error',
    message: err.message
    error: {}
  )
  return

logger.info('Routes registered')

###
  Fetch modpack information semi-asynchonously on application start
  The application will continue with the startup, but these tasks will execute one-by-one
###
solder = require('./controllers/solderAPI')
cl = require('./controllers/getChangelog')
await(solder.writeFullModList('technolution', defer()))
await(solder.writeFullModList('gates', defer()))
await(cl.createChangelog('technolution', defer()))
await(cl.createChangelog('gates', defer()))

###
  Register a scheduler after the above tasks are complete to keep modpack information up-to-date
  It will fetch new information every 60 mninutes
###
schedule = require('node-schedule')
schedule.scheduleJob '*/60 * * * *', ->
  await(solder.writeFullModList('technolution', defer()))
  await(solder.writeFullModList('gates', defer()))
  await(cl.createChangelog('technolution', defer()))
  await(cl.createChangelog('gates', defer()))
  return
logger.info('Tasks executed and re-scheduled')