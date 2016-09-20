express = require('express')
app = module.exports = express()

app.locals.defaultCookieExpiry = 30 * 24 * 60 * 60 * 1000

# Setup view engine
hbs = require('hbs')
path = require('path')
hbsHelperRegistrator = require('./controllers/hbsHelperRegistrator')
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'hbs'
hbsHelperRegistrator.registerHelpers hbs
hbs.registerPartials path.join(__dirname, 'views/partials')

# Connect to MySQL DB
db = require './controllers/databaseConnector'
db.connect (err) ->
  if err
    throw err
  else
    logger.info "Connected to #{dbConfig['db_name']} MySQL database"

# Setup session storage
session = require('express-session')
MySQLStore = require('express-mysql-session')(session)
sessionStore = new MySQLStore({}, db.get())
app.use(session({
  key: mainConfig['session_key'],
  secret: mainConfig['session_secret'],
  store: sessionStore,
  resave: true,
  saveUninitialized: true
}));
logger.info "MySQL session storage connected to #{dbConfig['db_name']}"

# Setup favicon and stylesheets
favicon = require('serve-favicon')
bodyParser = require('body-parser')
app.use favicon(path.join(__dirname, '../client/public', 'favicon.ico'))
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)

# Setup static folders
app.use express.static(path.join(__dirname, '../client/public'))

# Generate static data
staticGen = require('./controllers/staticGenerator')
staticGen.generateStaticInformation(app)

# Stuff all requests through the Global router first (for login, registration, cookies, permissions and things like that)
app.all '/*', require('./routes/global')

# Route incoming requests to the correct routes
app.use '/', require('./routes/index')
app.use '/a', require('./routes/administration')
app.use '/gates', require('./routes/modpacks/gates')
app.use '/technolution', require('./routes/modpacks/technolution')
app.use '/reset', require('./routes/reset')
#app.use '/profiles', require('./routes/profiles')
#app.use '/profilemanager', require('./routes/profilemanager')

schedule = require 'node-schedule'
solder = require './controllers/solderAPI'
solder.checkFullModLists(['technolution', 'gates'])
schedule.scheduleJob '* /15 * * * *', ->
  solder.checkFullModLists(['technolution', 'gates'])

# Catch 404 and show pretty error page
app.use (req, res) ->
  err = new Error('Not Found')
  err.status = 404
  res.render '404'

# error handlers
# development error handler
# will print stacktrace
if app.get('env') == 'development'
  app.use (err, req, res) ->
    res.status err.status or 500
    res.render 'error',
      message: err.message
      error: err

# production error handler
# no stacktraces leaked to user
app.use (err, req, res) ->
  res.status err.status or 500
  res.render 'error',
    message: err.message
    error: {}