exports.validateUsername = (username) ->
  re = /^(?!.*([_ .])\1{1})(?:[a-zA-Z0-9])([\w. ]{1,18})(?:[a-zA-Z0-9])$/
  re.test username

exports.validateEmail = (email) ->
  re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  re.test email

exports.validatePassword = (password) ->
  re = /^(?!.*([_ .])\1{1})(?:[a-zA-Z0-9])([\w. @#%?!]{4,})(?:[a-zA-Z0-9!?#])$/
  re.test password

exports.validateCookieTime = (cookieTime) ->
  re = /^\d+$/
  re.test cookieTime