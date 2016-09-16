$(document).ready ->
  usernameRegex = /^(?!.*([_ .])\1{1})(?:[a-zA-Z0-9])([\w. ]{1,18})(?:[a-zA-Z0-9])$/
  emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  passwordRegex = /^(?!.*([_ .])\1{1})(?:[a-zA-Z0-9])([\w. @#%?!]{4,})(?:[a-zA-Z0-9!?#])$/
  loginModal = $('#loginModal')
  loginModalTitle = $('.login .modal-title')
  loginModalBody = $('.login .modal-body')
  loginModalContent = $('.login .modal-content')
  loginForm = $('#loginForm')
  loginInputs = $('.login #loginForm input')
  loginUsername = $('#uLogin')
  loginPassword = $('#uPassword')
  loginErrorDiv = $('.login .loginError')
  loginErrorText = $('.login .loginError .login_error_text')
  loginButton = $('.login .modal-footer .btn')
  loginProgress = $('.login .progress')
  loginProgressbar = $('.login .progress .progress-bar')
  postLoginBody = $('.post-login')
  forgotPasswordButton = $('.forgot-password-button button')
  forgotPasswordButton2 = $('.forgot-password-button')
  forgotPasswordEmail = $('.forgot_password_input')
  registerModal = $('#registerModal')
  registerModalTitle = $('.register .modal-title')
  registerModalBody = $('.register .modal-body')
  registerModalContent = $('.register .modal-content')
  registerForm = $('#registerForm')
  registerInputs = $('.register #loginForm input')
  registerUsername = $('#uRegLogin')
  registerEmail = $('#uRegEmail')
  registerPassword = $('#uRegPassword')
  registerPassword2 = $('#uRegPassword2')
  registerErrorDiv = $('.register .registerError')
  registerErrorText = $('.register .registerError .register_error_text')
  registerButton = $('.register .modal-footer .btn')
  registerProgress = $('.register .progress')
  registerProgressbar = $('.register .progress .progress-bar')
  postRegisterBody = $('.post-register')

  setInvalid = (element) ->
    $(element + '_icon').css 'background-color': '#ff4136'
    $(element).attr 'data-valid', 'false'
    return

  setValid = (element) ->
    $(element + '_icon').css 'background-color': ''
    $(element).attr 'data-valid', 'true'
    return

  clearValid = (element) ->
    $(element + '_icon').css 'background-color': ''
    $(element).attr 'data-valid', 'false'
    return

  checkLoginButton = ->
    if loginUsername.attr('data-valid') == 'true' and loginPassword.attr('data-valid') == 'true'
      loginButton.removeClass 'disabled'
    else
      loginButton.addClass 'disabled'
    return

  checkRegisterButton = ->
    if registerUsername.attr('data-valid') == 'true' and registerEmail.attr('data-valid') == 'true' and registerPassword.attr('data-valid') == 'true' and registerPassword2.attr('data-valid') == 'true'
      registerButton.removeClass 'disabled'
    else
      registerButton.addClass 'disabled'
    return

  checkUsername = ->
    entry = loginUsername.val()
    if entry.length != 0
      if usernameRegex.test(entry) or emailRegex.test(entry)
        setValid '#uLogin'
      else
        setInvalid '#uLogin'
    else
      clearValid '#uLogin'
    checkLoginButton()
    return

  checkPassword = ->
    entry = loginPassword.val()
    if entry.length != 0
      if passwordRegex.test(entry)
        setValid '#uPassword'
      else
        setInvalid '#uPassword'
    else
      clearValid '#uPassword'
    checkLoginButton()
    return

  checkRegisterUsername = ->
    entry = registerUsername.val()
    if entry.length != 0
      if usernameRegex.test(entry)
        setValid '#uRegLogin'
      else
        setInvalid '#uRegLogin'
    else
      clearValid '#uRegLogin'
    checkRegisterButton()
    return

  checkRegisterEmail = ->
    entry = registerEmail.val()
    if entry.length != 0
      if emailRegex.test(entry)
        setValid '#uRegEmail'
      else
        setInvalid '#uRegEmail'
    else
      clearValid '#uRegEmail'
    checkRegisterButton()
    return

  checkRegisterPasswords = (passwordField) ->
    entry = passwordField.val()
    invalid = undefined
    if entry.length != 0
      if passwordRegex.test(entry)
        setValid '#' + passwordField.attr('id')
      else
        setInvalid '#' + passwordField.attr('id')
        invalid = true
      pass1 = registerPassword.val()
      pass2 = registerPassword2.val()
      if pass2 == pass1 and pass1.length != 0 and !invalid
        setValid '#' + registerPassword2.attr('id')
      else
        setInvalid '#' + registerPassword2.attr('id')
    else
      pass = registerPassword2.val()
      clearValid '#' + $(this).attr('id')
      if pass.length == 0
        clearValid '#pass2'
    checkRegisterButton()
    return

  completeLoginAttempt = (success) ->
    loginProgress.fadeOut ->
      loginProgressbar.attr('data-transitiongoal', 0).progressbar done: ->
        loginProgressbar.attr 'data-transitiongoal', 100
        return
      if success
        loginButton.text('Continue').removeClass('btn-primary').addClass('btn-success').removeClass('disabled').attr('data-dismiss', 'modal').blur().fadeIn()
        $(document).keypress (e) ->
          if e.which == 13
            loginModal.modal 'hide'
          return
      else
        loginButton.removeClass('disabled').fadeIn()
      return
    return

  completeRegisterAttempt = (success) ->
    registerProgress.fadeOut ->
      registerProgressbar.attr('data-transitiongoal', 0).progressbar done: ->
        registerProgressbar.attr 'data-transitiongoal', 100
        return
      if success
        registerButton.text('Continue').removeClass('disabled').attr('data-dismiss', 'modal').blur().fadeIn()
        $(document).keypress (e) ->
          if e.which == 13
            registerModal.modal 'hide'
          return
      else
        registerButton.removeClass('disabled').fadeIn()
      return
    return

  loginUsername.on 'input propertychange', ->
    checkUsername()
    return
  loginPassword.on 'input propertychange', ->
    checkPassword()
    return
  registerUsername.on 'input propertychange', ->
    checkRegisterUsername()
    return
  registerEmail.on 'input propertychange', ->
    checkRegisterEmail()
    return
  registerPassword.on 'input propertychange', ->
    checkRegisterPasswords registerPassword
    return
  registerPassword2.on 'input propertychange', ->
    checkRegisterPasswords registerPassword2
    return
  forgotPasswordButton.click ->
    loginModal.attr 'data-useful', 'true'
    $('.username_input').fadeOut ->
      forgotPasswordEmail.fadeIn()
      return
    $('.password_input').fadeOut()
    forgotPasswordButton2.fadeOut()
    loginModalContent.css 'height', '205px'
    loginModalTitle.fadeOut ->
      loginModalTitle.text 'Reset your password'
      loginModalTitle.fadeIn()
      return
    loginButton.fadeOut ->
      $('#forgotpasswordbutton').fadeIn()
      return
    return
  # Form interactions
  loginForm.submit (event) ->
    event.preventDefault()
    uLogin = loginUsername.val()
    uPassword = loginPassword.val()
    uLoginVal = usernameRegex.test(uLogin) or emailRegex.test(uLogin)
    uPasswordVal = passwordRegex.test(uPassword)
    if uLoginVal and uPasswordVal
      if loginButton.attr('data-dismiss') != 'modal'
        request_finished = false
        progressbar_done = false
        login_success = false
        user = undefined
        error = undefined
        loginProgressbar.attr 'data-transitiongoal', 0
        loginInputs.attr 'disabled', 'disabled'
        loginButton.fadeOut ->
          loginErrorDiv.fadeOut ->
            loginModalContent.css 'height', '295px'
            return
          loginButton.addClass 'disabled'
          loginProgress.fadeIn ->
            $.post('/login',
              user: uLogin
              password: uPassword).done((data) ->
              request_finished = true
              switch data[0]
                when 'valid_login'
                  login_success = true
                when 'incorrect_login', 'incorrect_password'
                  error = 'Username or password was incorrect.'
                when 'error_validation'
                  error = 'The text you entered did not pass validation.'
                when 'hash_check_error'
                  error = 'Your password could not be verified,\n please reset it.'
                else
                  error = 'An unknown error occurred, please try again.'
                  break
              user = data[1]
              $(document).trigger 'continueLoginEvent'
              return
            ).fail ->
              request_finished = true
              error = 'Login request failed.'
              $(document).trigger 'continueLoginEvent'
              return
            loginProgressbar.attr('data-transitiongoal', 100).progressbar done: ->
              progressbar_done = true
              $(document).trigger 'continueLoginEvent'
              return
            $(document).on 'continueLoginEvent', ->
              if request_finished and progressbar_done
                request_finished = false
                progressbar_done = false
                if login_success
                  loginModal.attr 'data-useful', 'true'
                  loginModalTitle.fadeOut ->
                    loginModalTitle.text 'Hello ' + user['username']
                    loginModalTitle.fadeIn()
                    return
                  loginModalBody.fadeOut ->
                    postLoginBody.fadeIn()
                    loginModalContent.css 'height', '170px'
                    return
                  completeLoginAttempt true
                else
                  loginErrorText.html error
                  loginErrorDiv.fadeIn()
                  dynamicHeight = loginModalContent.height() + loginErrorText.height()
                  loginModalContent.css 'height', dynamicHeight + 10 + 'px'
                  loginInputs.removeAttr 'disabled'
                  completeLoginAttempt false
              return
            return
          return
    return
  # Form interactions
  registerForm.submit (event) ->
    event.preventDefault()
    uUsername = registerUsername.val()
    uEmail = registerEmail.val()
    uPassword = registerPassword.val()
    uPassword2 = registerPassword2.val()
    uUsernameVal = usernameRegex.test(uUsername)
    uEmailVal = emailRegex.test(uEmail)
    uPasswordVal = passwordRegex.test(uPassword)
    uPassword2Val = passwordRegex.test(uPassword2)
    if uUsernameVal and uEmailVal and uPasswordVal and uPassword2Val and uPassword == uPassword2
      if registerButton.attr('data-dismiss') != 'modal'
        request_finished = false
        progressbar_done = false
        register_success = false
        user = undefined
        error = undefined
        registerProgressbar.attr 'data-transitiongoal', 0
        registerInputs.attr 'disabled', 'disabled'
        registerButton.fadeOut ->
          registerErrorDiv.fadeOut ->
            registerModalContent.css 'height', '365px'
            return
          registerButton.addClass 'disabled'
          registerProgress.fadeIn ->
            $.post('/register',
              username: uUsername
              email: uEmail
              password: uPassword).done((data) ->
              request_finished = true
              switch data[0]
                when 'account_created'
                  register_success = true
                when 'username_in_use'
                  error = 'The name \'' + uUsername + '\' is already in use.'
                when 'email_in_use'
                  error = 'This email is already in use.'
                when 'error_validation'
                  error = 'The values you entered did not pass validation.'
                when 'hash_check_error'
                  error = 'Your password could not be verified,\n please reset it.'
                else
                  error = 'An unknown error occurred, please try again.'
                  break
              user = data[1]
              $(document).trigger 'continueRegisterEvent'
              return
            ).fail ->
              request_finished = true
              error = 'Register request failed.'
              $(document).trigger 'continueRegisterEvent'
              return
            registerProgressbar.attr('data-transitiongoal', 100).progressbar done: ->
              progressbar_done = true
              $(document).trigger 'continueRegisterEvent'
              return
            $(document).on 'continueRegisterEvent', ->
              if request_finished and progressbar_done
                request_finished = false
                progressbar_done = false
                if register_success
                  registerModal.attr 'data-useful', 'true'
                  registerModalTitle.fadeOut ->
                    registerModalTitle.text 'Welcome ' + user['username']
                    registerModalTitle.fadeIn()
                    return
                  registerModalBody.fadeOut ->
                    postRegisterBody.fadeIn()
                    registerModalContent.css 'height', '170px'
                    return
                  completeRegisterAttempt true
                else
                  registerErrorText.html error
                  registerErrorDiv.fadeIn()
                  dynamicHeight = registerModalContent.height() + registerErrorText.height()
                  registerModalContent.css 'height', dynamicHeight + 10 + 'px'
                  registerInputs.removeAttr 'disabled'
                  completeRegisterAttempt false
              return
            return
          return
    return
  # Events for the login modal
  # Trigger on open event of modal
  loginModal.on 'shown.bs.modal', ->
# Check the input values in case the browser already filled them in
    checkUsername()
    checkPassword()
    return
  # Trigger on close event of modal
  loginModal.on 'hidden.bs.modal', ->
# Reload the page if modal did its job (login user)
    if loginModal.attr('data-useful') == 'true'
      location.reload()
    return
  # Events for the register modal
  # Trigger on open event of modal
  registerModal.on 'shown.bs.modal', ->
# Check the input values in case the browser already filled them in
    checkRegisterUsername()
    checkRegisterEmail()
    checkRegisterPasswords registerPassword
    checkRegisterPasswords registerPassword2
    return
  # Trigger on close event of modal
  registerModal.on 'hidden.bs.modal', ->
# Reload the page if modal did its job (login user)
    if registerModal.attr('data-useful') == 'true'
      location.reload()
    return
  return