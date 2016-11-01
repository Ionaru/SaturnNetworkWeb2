window.getProfile = (user) ->
  $.get("/profile/#{user}").done (profile) ->
    if profile
      $('#profile-username').text profile['user_name']
      $('#profile-email').text profile['user_email']
      $('#profile-register').text profile['user_registerdate']
      $('#profile-votes').text profile['user_timesvoted']
      $('#profile-points').text profile['user_points']
      if profile['user_mccharacter']
        $('#profile-mcimage').attr 'src', "https://cravatar.eu/helmhead/#{profile['user_mccharacter']}/128.png"
        $('#profile-mccharacter').text profile['user_mccharacter']
      else
        $('#profile-mcimage').attr 'src', 'https://cravatar.eu/helmhead/steve/128.png'
        $('#profile-mccharacter').text 'Not linked'
      $('#profileModal').modal 'show'
    return
  return
