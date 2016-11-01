exports.generateStaticInformation = (app) ->
  app.locals.title = 'The Saturn Server Network'
  app.locals.description = 'Home of modpacks like Technolution, Gates and more!'
  app.locals.keywords = 'Minecraft, Server, Saturn Server, Technolution, Gates'
  app.locals.author = 'Jeroen Akkerman (Ionaru)'
  return logger.info 'Finished loading static information'
