# coffeelint: disable=max_line_length
exports.validateUsername = (username) ->
  re = /^(?!.*([_ .])\1{1})(?:[a-zA-Z0-9])([\w. ]{1,18})(?:[a-zA-Z0-9])$/
  return re.test(username)

exports.validateEmail = (email) ->
  re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  return re.test(email)

exports.validatePassword = (password) ->
  re = /^(?!.*([_ .])\1{1})(?:[a-zA-Z0-9])([\w. @#%?!]{4,})(?:[a-zA-Z0-9!?#])$/
  return re.test(password)

exports.validateMinecraft = (name) ->
  re = /^[a-zA-Z0-9_]{1,16}$/
  return re.test(name)

exports.validateCookieTime = (cookieTime) ->
  re = /^\d+$/
  return re.test(cookieTime)

exports.validateToken = (token) ->
  re = /^[a-zA-Z0-9]*$/
  return re.test(token)

exports.validatePoints = (amount) ->
  re = /^[0-9]*$/
  return re.test(amount)
# coffeelint: enable=max_line_length