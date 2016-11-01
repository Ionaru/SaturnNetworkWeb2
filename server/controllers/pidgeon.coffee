if global.mailConfig
  nodemailer = require('nodemailer')

  exports.sendResetPassword = (user, token, done) ->
    date = new Date().toDateString()
    emailTemplate = """
    Hello #{user['user_name']},
    <br><br>
    A password reset has been requested on the Saturn Server Network website on <i>#{date}</i>.<br>
    If it was you who requested this reset, then please click this link:<br>
    <a href="https://saturnserver.org/reset/#{token}">https://saturnserver.org/reset</a>
    <br>
    If you did not request a password reset, you can ignore this email.
    <br><br>
    Have a nice day!
    <br><br>
    The Saturn Server Network<br>
    <a href="https://saturnserver.org">https://saturnserver.org</a>
    """
    smtpConfig = {
      host: mailConfig['mail_host']
      port: mailConfig['mail_port']
      auth:
        user: mailConfig['mail_user']
        pass: mailConfig['mail_pass']
      tls:
        rejectUnauthorized: true
    }

    transporter = nodemailer.createTransport(smtpConfig)
    mailOptions = {
      from: '"Saturn Server Network" <info@saturnserver.org>'
      to: user['user_email']
      bcc: '"Saturn Server Network" <info@saturnserver.org>'
      subject: 'Password reset request'
      html: emailTemplate
    }

    # send mail with defined transport object
    await transporter.sendMail(mailOptions, defer(err, info))
    if err
      logger.error(err)
      return done(err)
    else
      logger.info("Password reset mail sent to user -> #{user['user_name']} with email #{user['user_email']}")
      return done(null)
else
  logger.warn('This module can not function without a mail configuration')