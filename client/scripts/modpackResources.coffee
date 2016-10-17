window.getModList = (modpack) ->
  $.get("/#{modpack}/mod_list").done((data) ->
    modList = data
    if data
      content = ''
      content += "<p>Latest version: #{modList['modpackVersion']} for Minecraft #{modList['minecraftVersion']}</p>"
      content += '<table class="table table-hover table-responsive table-condensed sortable"
                  style="width:100%; table-layout: fixed;">'
      content += '<thead>'
      content += '<tr>'
      content += '<th class="text-left">Mod Name</th>'
      content += '<th class="text-left">Author</th>'
      content += '<th class="text-left">Version</th>'
      content += '<th class="text-right">Link</th>'
      content += '</tr>'
      content += '</thead>'
      content += '<tbody>'
      for modID of modList['mods']
        mod = modList['mods'][modID]
        content += '<tr>'
        content += '<td class="text-left">' + modID + '</td>'
        content += '<td class="text-left">' + mod['author'] + '</td>'
        content += '<td class="text-left">' + mod['version'] + '</td>'
        linkType = 'Mod Website'
        if mod['link'].search('minecraftforum') > -1
          linkType = 'Minecraft Forum'
        if mod['link'].search('curseforge') > -1
          linkType = 'Curse'
        if mod['link'].search('curse.com') > -1
          linkType = 'Curse'
        if mod['link'].search('github') > -1
          linkType = 'GitHub'
        if mod['link'].search('forum.industrial') > -1
          linkType = 'IC2 Forum'
        content += '<td class="text-right">
                    <a class="btn btn-primary btn-xs" href="' + mod['link'] + '" target="_blank" rel="external">
                    <i class="fa fa-external-link"></i> ' + linkType + '</a></td>'
        content += '</tr>'
      content += '</tbody>'
      content += '</table>'
      $('#content').html content
    else
      $('#content').html '<p>Unable to get mod list, please wait a few minutes and try again.</p>'
    return
  ).fail ->
  $('#content').html '<p>Unable to get mod list, please refresh the page to try again.</p>'
  return

window.getServerFiles = (modpack) ->
  $.get("/#{modpack}/serverfiles").done((data) ->
    err = data[0]
    filesList = data[1]
    if !err
      content = ''
      content += '<table class="table table-hover" style="width:100%; table-layout: fixed;">'
      content += '<thead>'
      content += '<tr>'
      content += '<th class="text-left">Version</th>'
      content += '<th class="text-left">Package size</th>'
      content += '<th class="text-right">Download</th>'
      content += '</tr>'
      content += '</thead>'
      content += '<tbody>'
      for packageID of filesList
        filePackage = filesList[packageID]
        if packageID == 0
          content += '<tr class="success">'
          content += '<td class="text-left">' + filePackage['version'] + ' - Latest</td>'
        else
          content += '<tr>'
          content += '<td class="text-left">' + filePackage['version'] + '</td>'
        packageSize = (filePackage['size'] / 1024 / 1024).toFixed(2)
        content += '<td class="text-left">' + packageSize + ' MB</td>'
        content += "<td class=\"text-right\">
                    <a class=\"btn btn-primary btn-xs\"
                      href=\"ftp://saturnserver.org/#{modpack}/#{filePackage['name']}\">
                        <i class=\"fa fa-download\"></i> Download
                    </a></td>"
        content += '</tr>'
      content += '<p class="text-right">Tip: check out these amazing projects to improve your server!<br>'
      content += '<a target="_blank" rel="external"
                    href="https://tcpr.ca/downloads/mcpc" class="btn btn-default btn-xs">
                      <i class="fa fa-external-link"></i> MCPC+ (up to 1.7.2)
                  </a> '
      content += '<a target="_blank" rel="external" href="https://gitlab.prok.pw/KCauldron/KCauldron"
                  class="btn btn-default btn-xs"><i class="fa fa-external-link"></i> KCauldron (1.7.10)</a> '
      content += '<a target="_blank" rel="external" href="https://www.spongepowered.org/"
                  class="btn btn-default btn-xs"><i class="fa fa-external-link"></i> Sponge (1.8 and up)</a></p>'
      content += '</tbody>'
      content += '</table>'
      $('#server-files-content').html content
    else
      $('#server-files-content').html '<p>Unable to fetch the server files,
                                          please wait a few minutes and try again.</p>'
    return
  ).fail ->
  $('#server-files-content').html '<p>Unable to fetch the server files, please refresh the page to try again.</p>'
  return

window.copyTextToClipboard = (text) ->
  textArea = document.createElement('textarea')
  #
  # *** This styling is an extra step which is likely not required. ***
  #
  # Why is it here? To ensure:
  # 1. the element is able to have focus and selection.
  # 2. if element was to flash render it has minimal visual impact.
  # 3. less flakyness with selection and copying which **might** occur if
  #    the textarea element is not visible.
  #
  # The likelihood is the element won't even render, not even a flash,
  # so some of these are just precautions. However in IE the element
  # is visible whilst the popup box asking the user for permission for
  # the web page to copy to the clipboard.
  #
  # Place in top-left corner of screen regardless of scroll position.
  textArea.style.position = 'fixed'
  textArea.style.top = 0
  textArea.style.left = 0
  # Ensure it has a small width and height. Setting to 1px / 1em
  # doesn't work as this gives a negative w/h on some browsers.
  textArea.style.width = '2em'
  textArea.style.height = '2em'
  # We don't need padding, reducing the size if it does flash render.
  textArea.style.padding = 0
  # Clean up any borders.
  textArea.style.border = 'none'
  textArea.style.outline = 'none'
  textArea.style.boxShadow = 'none'
  # Avoid flash of white box if rendered for any reason.
  textArea.style.background = 'transparent'
  textArea.value = text
  document.body.appendChild textArea
  textArea.select()
  copyButton = $('#copyModpackLink').find('.btnText')
  try
    document.execCommand 'copy'
    copyButton.text 'Link copied'
  catch err
    copyButton.text 'Copy failed'
  document.body.removeChild textArea
  return