db = require('./databaseConnector')

exports.generateStaticInformation = (app) ->
  app.locals.title = "The Saturn Server Network"
  app.locals.description = "The Saturn Server Network is a place where modders and modpack makers can coordinate."
  app.locals.keywords = "Minecraft, Server, Saturn Server, Technolution, Gates"
  app.locals.author = "Jeroen Akkerman"
  logger.info "Finished loading static information"
