Client = require('ftp')

exports.getServerFiles = (modpack, done) ->
  serverFiles = []
  c = new Client()
  c.on 'ready', ->
    c.list modpack, (err, list) ->
      if err
        throw err
      versions = []
      for file in list
        if file['type'] is '-'
          version = file['name'].substring(file['name'].lastIndexOf('_') + 1, file['name'].lastIndexOf('.'))
          versions.push(version)
          serverFiles[version] =
            name: file['name']
            version: version
            size: file['size']
      versions = versions.sort().reverse()
      versionsFinal = []
      for versionID in versions
        versionsFinal.push serverFiles[versionID]
      c.end()
      done null, versionsFinal

  c.connect(
    host: '85.25.237.10'
    user: 'serverfiles'
  )
