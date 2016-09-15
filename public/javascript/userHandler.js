$(document).ready(function () {

    var usernameRegex = /^(?!.*([_ .])\1{1})(?:[a-zA-Z0-9])([\w. ]{1,18})(?:[a-zA-Z0-9])$/;
    var emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    var passwordRegex = /^(?!.*([_ .])\1{1})(?:[a-zA-Z0-9])([\w. @#%?!]{4,})(?:[a-zA-Z0-9!?#])$/;

    var loginModal = $('#loginModal');
    var loginModalTitle = $('.login .modal-title');
    var loginModalBody = $('.login .modal-body');
    var loginModalContent = $('.login .modal-content');
    var loginForm = $('#loginForm');
    var loginInputs = $('.login #loginForm input');
    var loginUsername = $('#uLogin');
    var loginPassword = $('#uPassword');
    var loginErrorDiv = $('.login .loginError');
    var loginErrorText = $('.login .loginError .login_error_text');
    var loginButton = $('.login .modal-footer .btn');
    var loginProgress = $('.login .progress');
    var loginProgressbar = $('.login .progress .progress-bar');
    var postLoginBody = $('.post-login');
    var forgotPasswordButton = $('.forgot-password-button button');
    var forgotPasswordButton2 = $('.forgot-password-button');
    var forgotPasswordEmail = $('.forgot_password_input');

    var registerModal = $('#registerModal');
    var registerModalTitle = $('.register .modal-title');
    var registerModalBody = $('.register .modal-body');
    var registerModalContent = $('.register .modal-content');
    var registerForm = $('#registerForm');
    var registerInputs = $('.register #loginForm input');
    var registerUsername = $('#uRegLogin');
    var registerEmail = $('#uRegEmail');
    var registerPassword = $('#uRegPassword');
    var registerPassword2 = $('#uRegPassword2');
    var registerErrorDiv = $('.register .registerError');
    var registerErrorText = $('.register .registerError .register_error_text');
    var registerButton = $('.register .modal-footer .btn');
    var registerProgress = $('.register .progress');
    var registerProgressbar = $('.register .progress .progress-bar');
    var postRegisterBody = $('.post-register');

    function setInvalid(element) {
        $(element + '_icon').css({"background-color": "#ff4136"});
        $(element).attr("data-valid", "false");
    }

    function setValid(element) {
        $(element + '_icon').css({"background-color": ""});
        $(element).attr("data-valid", "true");
    }

    function clearValid(element) {
        $(element + '_icon').css({"background-color": ""});
        $(element).attr("data-valid", "false");
    }

    function checkLoginButton() {
        if (loginUsername.attr('data-valid') === 'true' &&
            loginPassword.attr('data-valid') === 'true') {
            loginButton.removeClass("disabled");
        } else {
            loginButton.addClass("disabled");
        }
    }

    function checkRegisterButton() {
        if (registerUsername.attr('data-valid') === 'true' &&
            registerEmail.attr('data-valid') === 'true' &&
            registerPassword.attr('data-valid') === 'true' &&
            registerPassword2.attr('data-valid') === 'true') {
            registerButton.removeClass("disabled");
        } else {
            registerButton.addClass("disabled");
        }
    }

    function checkUsername() {
        var entry = loginUsername.val();
        if (entry.length !== 0) {
            if (usernameRegex.test(entry) || emailRegex.test(entry)) {
                setValid("#uLogin");
            } else {
                setInvalid("#uLogin");
            }
        } else {
            clearValid("#uLogin");
        }
        checkLoginButton();
    }

    function checkPassword() {
        var entry = loginPassword.val();
        if (entry.length !== 0) {
            if (passwordRegex.test(entry)) {
                setValid("#uPassword");
            } else {
                setInvalid("#uPassword");
            }
        } else {
            clearValid("#uPassword");
        }
        checkLoginButton();
    }

    function checkRegisterUsername() {
        var entry = registerUsername.val();
        if (entry.length !== 0) {
            if (usernameRegex.test(entry)) {
                setValid("#uRegLogin");
            } else {
                setInvalid("#uRegLogin");
            }
        } else {
            clearValid("#uRegLogin");
        }
        checkRegisterButton();
    }

    function checkRegisterEmail() {
        var entry = registerEmail.val();
        if (entry.length !== 0) {
            if (emailRegex.test(entry)) {
                setValid("#uRegEmail");
            } else {
                setInvalid("#uRegEmail");
            }
        } else {
            clearValid("#uRegEmail");
        }
        checkRegisterButton();
    }

    function checkRegisterPasswords(passwordField) {
        var entry = passwordField.val();
        var invalid;
        if (entry.length !== 0) {
            if (passwordRegex.test(entry)) {
                setValid('#' + passwordField.attr('id'));
            } else {
                setInvalid('#' + passwordField.attr('id'));
                invalid = true;
            }
            var pass1 = registerPassword.val();
            var pass2 = registerPassword2.val();
            if (pass2 === pass1 && pass1.length !== 0 && !invalid) {
                setValid('#' + registerPassword2.attr('id'));
            } else {
                setInvalid('#' + registerPassword2.attr('id'));
            }
        } else {
            var pass = registerPassword2.val();
            clearValid('#' + $(this).attr('id'));
            if (pass.length === 0) {
                clearValid('#pass2');
            }
        }
        checkRegisterButton();
    }

    loginUsername.on("input propertychange", function () {
        checkUsername();
    });

    loginPassword.on("input propertychange", function () {
        checkPassword();
    });

    registerUsername.on("input propertychange", function () {
        checkRegisterUsername();
    });

    registerEmail.on("input propertychange", function () {
        checkRegisterEmail();
    });

    registerPassword.on("input propertychange", function () {
        checkRegisterPasswords(registerPassword);
    });

    registerPassword2.on("input propertychange", function () {
        checkRegisterPasswords(registerPassword2);
    });

    forgotPasswordButton.click(function () {
        loginModal.attr('data-useful', 'true');
        $('.username_input').fadeOut(function () {
            forgotPasswordEmail.fadeIn();
        });
        $('.password_input').fadeOut();
        forgotPasswordButton2.fadeOut();
        loginModalContent.css('height', '205px');
        loginModalTitle.fadeOut(function () {
            loginModalTitle.text("Reset your password");
            loginModalTitle.fadeIn();
        });
        loginButton.fadeOut(function() {
            $('#forgotpasswordbutton').fadeIn();
        });
    });

    // Form interactions
    loginForm.submit(function (event) {
        event.preventDefault();
        var uLogin = loginUsername.val();
        var uPassword = loginPassword.val();
        var uLoginVal = usernameRegex.test(uLogin) || emailRegex.test(uLogin);
        var uPasswordVal = passwordRegex.test(uPassword);

        if (uLoginVal && uPasswordVal) {
            if (loginButton.attr("data-dismiss") != "modal") {

                var request_finished = false;
                var progressbar_done = false;
                var login_success = false;
                var user, error;

                loginProgressbar.attr('data-transitiongoal', 0);
                loginInputs.attr("disabled", "disabled");

                loginButton.fadeOut(function () {
                    loginErrorDiv.fadeOut(function () {
                        loginModalContent.css('height', '295px');
                    });
                    loginButton.addClass("disabled");
                    loginProgress.fadeIn(function () {
                        $.post("/login", {user: uLogin, password: uPassword}
                        ).done(function (data) {
                            request_finished = true;
                            switch (data[0]) {
                                case "valid_login":
                                    login_success = true;
                                    break;
                                case "incorrect_login":
                                case "incorrect_password":
                                    error = "Username or password was incorrect.";
                                    break;
                                case "error_validation":
                                    error = "The text you entered did not pass validation.";
                                    break;
                                case "hash_check_error":
                                    error = "Your password could not be verified,\n please reset it.";
                                    break;
                                default:
                                    error = "An unknown error occurred, please try again.";
                                    break;
                            }
                            user = data[1];
                            $(document).trigger("continueLoginEvent");
                        }).fail(function () {
                            request_finished = true;
                            error = "Login request failed.";
                            $(document).trigger("continueLoginEvent");
                        });

                        loginProgressbar.attr('data-transitiongoal', 100).progressbar({
                            done: function () {
                                progressbar_done = true;
                                $(document).trigger("continueLoginEvent");
                            }
                        });

                        $(document).on("continueLoginEvent", function () {
                            if (request_finished && progressbar_done) {
                                request_finished = false;
                                progressbar_done = false;
                                if (login_success) {
                                    loginModal.attr('data-useful', 'true');
                                    loginModalTitle.fadeOut(function () {
                                        loginModalTitle.text("Hello " + user['username']);
                                        loginModalTitle.fadeIn();
                                    });
                                    loginModalBody.fadeOut(function() {
                                        postLoginBody.fadeIn();
                                        loginModalContent.css('height', '170px');
                                    });
                                    completeLoginAttempt(true)
                                }
                                else {
                                    loginErrorText.html(error);
                                    loginErrorDiv.fadeIn();
                                    var dynamicHeight = (loginModalContent.height() + loginErrorText.height());
                                    loginModalContent.css('height', (dynamicHeight + 10) + 'px');
                                    loginInputs.removeAttr("disabled");
                                    completeLoginAttempt(false)
                                }
                            }
                        });

                    });
                });
            }
        }
    });

    // Form interactions
    registerForm.submit(function (event) {
        event.preventDefault();
        var uUsername = registerUsername.val();
        var uEmail = registerEmail.val();
        var uPassword = registerPassword.val();
        var uPassword2 = registerPassword2.val();
        var uUsernameVal = usernameRegex.test(uUsername);
        var uEmailVal = emailRegex.test(uEmail);
        var uPasswordVal = passwordRegex.test(uPassword);
        var uPassword2Val = passwordRegex.test(uPassword2);

        if (uUsernameVal && uEmailVal && uPasswordVal && uPassword2Val && (uPassword == uPassword2)) {
            if (registerButton.attr("data-dismiss") != "modal") {

                var request_finished = false;
                var progressbar_done = false;
                var register_success = false;
                var user, error;

                registerProgressbar.attr('data-transitiongoal', 0);
                registerInputs.attr("disabled", "disabled");

                registerButton.fadeOut(function () {
                    registerErrorDiv.fadeOut(function () {
                        registerModalContent.css('height', '365px');
                    });
                    registerButton.addClass("disabled");
                    registerProgress.fadeIn(function () {
                        $.post("/register", {username: uUsername, email: uEmail, password: uPassword}
                        ).done(function (data) {
                            request_finished = true;
                            switch (data[0]) {
                                case "account_created":
                                    register_success = true;
                                    break;
                                case "username_in_use":
                                    error = "The name '" + uUsername + "' is already in use.";
                                    break;
                                case "email_in_use":
                                    error = "This email is already in use.";
                                    break;
                                case "error_validation":
                                    error = "The values you entered did not pass validation.";
                                    break;
                                case "hash_check_error":
                                    error = "Your password could not be verified,\n please reset it.";
                                    break;
                                default:
                                    error = "An unknown error occurred, please try again.";
                                    break;
                            }
                            user = data[1];
                            $(document).trigger("continueRegisterEvent");
                        }).fail(function () {
                            request_finished = true;
                            error = "Register request failed.";
                            $(document).trigger("continueRegisterEvent");
                        });

                        registerProgressbar.attr('data-transitiongoal', 100).progressbar({
                            done: function () {
                                progressbar_done = true;
                                $(document).trigger("continueRegisterEvent");
                            }
                        });

                        $(document).on("continueRegisterEvent", function () {
                            if (request_finished && progressbar_done) {
                                request_finished = false;
                                progressbar_done = false;
                                if (register_success) {
                                    registerModal.attr('data-useful', 'true');
                                    registerModalTitle.fadeOut(function () {
                                        registerModalTitle.text("Welcome " + user['username']);
                                        registerModalTitle.fadeIn();
                                    });
                                    registerModalBody.fadeOut(function() {
                                        postRegisterBody.fadeIn();
                                        registerModalContent.css('height', '170px');
                                    });
                                    completeRegisterAttempt(true)
                                }
                                else {
                                    registerErrorText.html(error);
                                    registerErrorDiv.fadeIn();
                                    var dynamicHeight = registerModalContent.height() + registerErrorText.height();
                                    registerModalContent.css('height', (dynamicHeight + 10) + 'px');
                                    registerInputs.removeAttr("disabled");
                                    completeRegisterAttempt(false)
                                }
                            }
                        });
                    });
                });
            }
        }
    });

    function completeLoginAttempt(success) {
        loginProgress.fadeOut(function () {
            loginProgressbar.attr('data-transitiongoal', 0).progressbar({
                done: function () {
                    loginProgressbar.attr('data-transitiongoal', 100)
                }
            });
            if (success) {
                loginButton.text("Continue")
                    .removeClass("btn-primary")
                    .addClass("btn-success")
                    .removeClass("disabled")
                    .attr("data-dismiss", "modal")
                    .blur()
                    .fadeIn();
                $(document).keypress(function (e) {
                    if (e.which == 13) {
                        loginModal.modal('hide');
                    }
                });
            }
            else {
                loginButton.removeClass("disabled")
                    .fadeIn();
            }
        });
    }

    function completeRegisterAttempt(success) {
        registerProgress.fadeOut(function () {
            registerProgressbar.attr('data-transitiongoal', 0).progressbar({
                done: function () {
                    registerProgressbar.attr('data-transitiongoal', 100)
                }
            });
            if (success) {
                registerButton.text("Continue")
                    .removeClass("disabled")
                    .attr("data-dismiss", "modal")
                    .blur()
                    .fadeIn();
                $(document).keypress(function (e) {
                    if (e.which == 13) {
                        registerModal.modal('hide');
                    }
                });
            }
            else {
                registerButton.removeClass("disabled")
                    .fadeIn();
            }
        });
    }

    // Events for the login modal

    // Trigger on open event of modal
    loginModal.on('shown.bs.modal', function () {
        // Check the input values in case the browser already filled them in
        checkUsername();
        checkPassword();
    });

    // Trigger on close event of modal
    loginModal.on('hidden.bs.modal', function () {
        // Reload the page if modal did its job (login user)
        if (loginModal.attr('data-useful') == 'true') {
            location.reload();
        }
    });

    // Events for the register modal

    // Trigger on open event of modal
    registerModal.on('shown.bs.modal', function () {
        // Check the input values in case the browser already filled them in
        checkRegisterUsername();
        checkRegisterEmail();
        checkRegisterPasswords(registerPassword);
        checkRegisterPasswords(registerPassword2)
    });

    // Trigger on close event of modal
    registerModal.on('hidden.bs.modal', function () {
        // Reload the page if modal did its job (login user)
        if (registerModal.attr('data-useful') == 'true') {
            location.reload();
        }
    });
});