$(document).ready ->
# coffeelint: disable=max_line_length
  usernameRegex = /^(?!.*([_ .])\1{1})(?:[a-zA-Z0-9])([\w. ]{1,18})(?:[a-zA-Z0-9])$/
  emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
  passwordRegex = /^(?!.*([_ .])\1{1})(?:[a-zA-Z0-9])([\w. @#%?!]{4,})(?:[a-zA-Z0-9!?#])$/
  # coffeelint: enable=max_line_length

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
  loginButton = $('.login .modal-footer #loginbutton')
  loginProgress = $('.login .progress')
  loginProgressbar = $('.login .progress .progress-bar')
  postLoginBody = $('.post-login')

  forgotPasswordButton = $('.forgot-password-button')
  forgotPasswordSubmit = $('#forgotpasswordbutton')
  forgotPasswordInput = $('.forgot_password_input')
  forgotPasswordEmail = $('#uForgot_Email')
  postResetBody = $('.post-reset')

  changePasswordModal = $('#passwordModal')
  changePasswordTitle = $('#changeModelTitle')
  changePasswordContent = $('#passwordModal .modal-content')
  changePasswordForm = $('#changeForm')
  changePasswordBody = $('#changeForm .modal-body')
  changePasswordInputs = $('#changeForm input')
  changePasswordInputOld = $('#uOldPassword')
  changePasswordInputNew = $('#uNewPassword')
  changePasswordInputNew2 = $('#uNewPassword2')
  changePasswordSubmit = $('#changebutton')
  changeErrorDiv = $('.changeError')
  changeErrorText = $('.change_error_text')
  changeProgress = $('.password .progress')
  changeProgressbar = $('.password .progress .progress-bar')
  postChangeBody = $('.post-change')

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

  setValid = (element) ->
    $(element + '_icon').css 'background-color': ''
    $(element).attr 'data-valid', 'true'

  clearValid = (element) ->
    $(element + '_icon').css 'background-color': ''
    $(element).attr 'data-valid', 'false'

  checkLoginButton = ->
    if loginUsername.attr('data-valid') == 'true' and loginPassword.attr('data-valid') == 'true'
      loginButton.removeClass 'disabled'
    else
      loginButton.addClass 'disabled'

  checkResetButton = ->
    if forgotPasswordEmail.attr('data-valid') == 'true'
      forgotPasswordSubmit.removeClass 'disabled'
    else
      forgotPasswordSubmit.addClass 'disabled'

  checkRegisterButton = ->
    if (registerUsername.attr('data-valid') == 'true' and registerEmail.attr('data-valid') == 'true' and
        registerPassword.attr('data-valid') == 'true' and registerPassword2.attr('data-valid') == 'true')
      registerButton.removeClass 'disabled'
    else
      registerButton.addClass 'disabled'

  checkChangeButton = ->
    if changePasswordInputOld.attr('data-valid') == 'true' and changePasswordInputNew.attr('data-valid') == 'true' and
        changePasswordInputNew2.attr('data-valid') == 'true'
      changePasswordSubmit.removeClass 'disabled'
    else
      changePasswordSubmit.addClass 'disabled'

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

  checkForgotEmail = ->
    entry = forgotPasswordEmail.val()
    if entry.length != 0
      if emailRegex.test(entry)
        setValid '#uForgot_Email'
      else
        setInvalid '#uForgot_Email'
    else
      clearValid '#uForgot_Email'
    checkResetButton()

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
      clearValid '#uRegPassword'
      pass = registerPassword2.val()
      if pass.length == 0
        clearValid '#uRegPassword2'
    checkRegisterButton()

  checkChangePassword = ->
    entry = changePasswordInputOld.val()
    if entry.length != 0
      if passwordRegex.test(entry)
        setValid '#uOldPassword'
      else
        setInvalid '#uOldPassword'
    else
      clearValid '#uOldPassword'
    checkChangeButton()

  checkChangePasswords = (passwordField) ->
    entry = passwordField.val()
    invalid = undefined
    if entry.length != 0
      if passwordRegex.test(entry)
        setValid '#' + passwordField.attr('id')
      else
        setInvalid '#' + passwordField.attr('id')
        invalid = true
      pass1 = changePasswordInputNew.val()
      pass2 = changePasswordInputNew2.val()
      if pass2 == pass1 and pass1.length != 0 and !invalid
        setValid '#' + changePasswordInputNew2.attr('id')
      else
        setInvalid '#' + changePasswordInputNew2.attr('id')
    else
      clearValid '#uNewPassword'
      pass = changePasswordInputNew2.val()
      if pass.length == 0
        clearValid '#uNewPassword2'
    checkChangeButton()

  completeLoginAttempt = (success) ->
    loginProgress.fadeOut ->
      loginProgressbar.attr('data-transitiongoal', 0).progressbar done: ->
        loginProgressbar.attr 'data-transitiongoal', 100
      if success
        loginButton.text('Continue')
        .removeClass('btn-primary')
        .addClass('btn-success')
        .removeClass('disabled')
        .attr('data-dismiss', 'modal')
        .blur()
        .fadeIn()
        $(document).keypress (e) ->
          if e.which == 13
            loginModal.modal 'hide'
      else
        loginButton.removeClass('disabled').fadeIn()

  completeResetAttempt = (success) ->
    if success
      forgotPasswordSubmit.fadeOut ->
        loginButton
        .text('Close')
        .removeClass('btn-primary')
        .addClass('btn-primary')
        .removeClass('disabled')
        .attr('data-dismiss', 'modal')
        .blur()
        .fadeIn()
        $(document).keypress (e) ->
          if e.which == 13
            loginModal.modal 'hide'

  completeRegisterAttempt = (success) ->
    registerProgress.fadeOut ->
      registerProgressbar.attr('data-transitiongoal', 0).progressbar done: ->
        registerProgressbar.attr 'data-transitiongoal', 100
      if success
        registerButton.text('Continue').removeClass('disabled').attr('data-dismiss', 'modal').blur().fadeIn()
        $(document).keypress (e) ->
          if e.which == 13
            registerModal.modal 'hide'
          return
      else
        registerButton.removeClass('disabled').fadeIn()

  loginUsername.on 'input propertychange', ->
    checkUsername()

  loginPassword.on 'input propertychange', ->
    checkPassword()

  forgotPasswordEmail.on 'input propertychange', ->
    checkForgotEmail()

  registerUsername.on 'input propertychange', ->
    checkRegisterUsername()

  registerEmail.on 'input propertychange', ->
    checkRegisterEmail()

  registerPassword.on 'input propertychange', ->
    checkRegisterPasswords registerPassword

  registerPassword2.on 'input propertychange', ->
    checkRegisterPasswords registerPassword2

  changePasswordInputOld.on 'input propertychange', ->
    checkChangePassword()

  changePasswordInputNew.on 'input propertychange', ->
    checkChangePasswords changePasswordInputNew

  changePasswordInputNew2.on 'input propertychange', ->
    checkChangePasswords changePasswordInputNew2

  forgotPasswordButton.click ->
    loginErrorDiv.fadeOut()
    loginModal.attr 'data-useful', 'true'
    loginModal.attr 'data-modal-mode', 'reset'
    $('.username_input').fadeOut ->
      forgotPasswordInput.fadeIn()
    $('.password_input').fadeOut()
    forgotPasswordButton.fadeOut()
    loginModalContent.css 'height', '205px'
    loginModalTitle.fadeOut ->
      loginModalTitle.text 'Reset your password'
      loginModalTitle.fadeIn()
    loginButton.fadeOut ->
      $('#forgotpasswordbutton').fadeIn()

  # Form interactions
  loginForm.submit (event) ->
    event.preventDefault()
    if loginModal.attr('data-modal-mode') is 'login'
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
                  continueLoginEvent()
              ).fail ->
                request_finished = true
                error = 'Login request failed.'
                continueLoginEvent()

              loginProgressbar.attr('data-transitiongoal', 100).progressbar done: ->
                progressbar_done = true
                continueLoginEvent()

              continueLoginEvent = ->
                if request_finished and progressbar_done
                  request_finished = false
                  progressbar_done = false
                  if login_success
                    loginModal.attr 'data-useful', 'true'
                    loginModalTitle.fadeOut ->
                      loginModalTitle.text 'Hello ' + user['username']
                      loginModalTitle.fadeIn()
                    loginModalBody.fadeOut ->
                      postLoginBody.fadeIn()
                      loginModalContent.css 'height', '170px'
                    completeLoginAttempt true
                  else
                    loginErrorText.html error
                    loginErrorDiv.fadeIn()
                    dynamicHeight = loginModalContent.height() + loginErrorText.height()
                    loginModalContent.css 'height', dynamicHeight + 10 + 'px'
                    loginInputs.removeAttr 'disabled'
                    completeLoginAttempt false

    if loginModal.attr('data-modal-mode') is 'reset'
      uEmail = forgotPasswordEmail.val()
      uEmailVal = emailRegex.test(uEmail)
      if uEmailVal
        reset_success = false
        error = undefined
        loginErrorDiv.fadeOut ->
          loginModalContent.css 'height', '205px'
          forgotPasswordSubmit.addClass('disabled')
          $.post('/reset',
            email: uEmail
          ).done((data) ->
            switch data[0]
              when 'password_reset'
                reset_success = true
              when 'incorrect_email'
                error = 'No User was found for that email.'
              when 'error_mail'
                error = 'Error while sending mail.'
              when 'token_error'
                error = 'Error while making token.'
              when 'error_user'
                error = 'Error in User.'
              when 'error_validation'
                error = 'The email you entered did not pass validation.'
              else
                error = 'An unknown error occurred, please try again.'
                break
          ).fail(->
            error = 'Reset request failed.'
          ).always ->
            forgotPasswordSubmit.removeClass('disabled')
            if reset_success
              loginModal.attr 'data-useful', 'true'
              loginModalTitle.fadeOut ->
                loginModalTitle.text 'Reset request complete'
                loginModalTitle.fadeIn()
              loginModalBody.fadeOut ->
                postResetBody.fadeIn()
                loginModalContent.css 'height', '185px'
              completeResetAttempt true
            else
              loginErrorText.html error
              loginErrorDiv.fadeIn()
              dynamicHeight = 205 + loginErrorText.height()
              loginModalContent.css 'height', dynamicHeight + 10 + 'px'
              loginInputs.removeAttr 'disabled'
              completeResetAttempt false

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
                  else
                    error = 'An unknown error occurred, please try again.'
                    break
                user = data[1]
                continueRegisterEvent()
            ).fail ->
              request_finished = true
              error = 'Register request failed.'
              continueRegisterEvent()

            registerProgressbar.attr('data-transitiongoal', 100).progressbar done: ->
              progressbar_done = true
              continueRegisterEvent()

            continueRegisterEvent = ->
              if request_finished and progressbar_done
                request_finished = false
                progressbar_done = false
                if register_success
                  registerModal.attr 'data-useful', 'true'
                  registerModalTitle.fadeOut ->
                    registerModalTitle.text 'Welcome ' + user['username']
                    registerModalTitle.fadeIn()
                  registerModalBody.fadeOut ->
                    postRegisterBody.fadeIn()
                    registerModalContent.css 'height', '170px'
                  completeRegisterAttempt true
                else
                  registerErrorText.html error
                  registerErrorDiv.fadeIn()
                  dynamicHeight = registerModalContent.height() + registerErrorText.height()
                  registerModalContent.css 'height', dynamicHeight + 10 + 'px'
                  registerInputs.removeAttr 'disabled'
                  completeRegisterAttempt false

  # Form interactions
  changePasswordForm.submit (event) ->
    event.preventDefault()
    if changePasswordSubmit.attr('data-dismiss') != 'modal'
      uPasswordOld = changePasswordInputOld.val()
      uPasswordNew = changePasswordInputNew.val()
      uPasswordConfirm = changePasswordInputNew2.val()
      vPasswordOld = passwordRegex.test(uPasswordOld)
      vPasswordNew = passwordRegex.test(uPasswordNew)
      vPasswordConfirm = passwordRegex.test(uPasswordConfirm)
      if vPasswordOld and vPasswordNew and vPasswordConfirm and uPasswordNew == uPasswordConfirm
        request_finished = false
        progressbar_done = false
        change_success = false
        error = undefined
        changeProgressbar.attr 'data-transitiongoal', 0
        changePasswordInputs.attr 'disabled', 'disabled'
        changePasswordSubmit.fadeOut ->
          changeErrorDiv.fadeOut ->
            changePasswordContent.css 'height', '312px'
          changePasswordSubmit.addClass 'disabled'
          changeProgress.fadeIn ->
            $.post('/change_password',
              old: uPasswordOld
              new: uPasswordNew).done((data) ->
                request_finished = true
                switch data
                  when 'password_changed'
                    change_success = true
                  when 'incorrect_password'
                    error = 'The password you entered did not match your current password'
                  when 'same_password'
                    error = 'You didn\'t really change a lot, did you?'
                  when 'error_validation'
                    error = 'The values you entered did not pass validation.'
                  else
                    error = 'An unknown error occurred, please try again.'
                    break
                continueChangeEvent()
            ).fail ->
              request_finished = true
              error = 'Change request failed.'
              continueChangeEvent()

            changeProgressbar.attr('data-transitiongoal', 100).progressbar done: ->
              progressbar_done = true
              continueChangeEvent()

            completeChangeAttempt = (success) ->
              changeProgress.fadeOut ->
                changeProgressbar.attr('data-transitiongoal', 0).progressbar done: ->
                  changeProgressbar.attr 'data-transitiongoal', 100
                if success
                  changePasswordSubmit
                  .text('Close')
                  .removeClass('disabled')
                  .attr('data-dismiss', 'modal')
                  .blur()
                  .fadeIn()
                  $(document).keypress (e) ->
                    if e.which == 13
                      changePasswordModal.modal 'hide'
                    return
                else
                  changePasswordSubmit.removeClass('disabled').fadeIn()

            continueChangeEvent = ->
              if request_finished and progressbar_done
                request_finished = false
                progressbar_done = false
                if change_success
                  changePasswordModal.attr 'data-useful', 'true'
                  changePasswordTitle.fadeOut ->
                    changePasswordTitle.text 'Password changed'
                    changePasswordTitle.fadeIn()
                  changePasswordBody.fadeOut ->
                    postChangeBody.fadeIn()
                    changePasswordContent.css 'height', '170px'
                  completeChangeAttempt true
                else
                  changeErrorText.html error
                  changeErrorDiv.fadeIn()
                  changePasswordContent.css 'height', '350px'
                  changePasswordInputs.removeAttr 'disabled'
                  completeChangeAttempt false


  # Events for the login modal
  # Trigger on open event of modal
  loginModal.on 'shown.bs.modal', ->
# Check the input values in case the browser already filled them in
    if loginUsername.val().length is 0
      loginUsername.focus()
    else
      loginPassword.focus()
    checkUsername()
    checkPassword()

  # Trigger on close event of modal
  loginModal.on 'hidden.bs.modal', ->
# Reload the page if modal did its job (login user)
    if loginModal.attr('data-useful') == 'true'
      location.reload()

  # Events for the register modal
  # Trigger on open event of modal
  registerModal.on 'shown.bs.modal', ->
# Check the input values in case the browser already filled them in
    registerUsername.focus()
    checkRegisterUsername()
    checkRegisterEmail()
    checkRegisterPasswords registerPassword

  # Trigger on close event of modal
  registerModal.on 'hidden.bs.modal', ->
# Reload the page if modal did its job (Register user)
    if registerModal.attr('data-useful') == 'true'
      location.reload()

  # Events for the change modal
  # Trigger on close event of modal
  changePasswordModal.on 'hidden.bs.modal', ->
# Reload the page if modal did its job (Change password)
    if changePasswordModal.attr('data-useful') == 'true'
      location.reload()