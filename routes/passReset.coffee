express = require('express')
router = express.Router()
nodemailer = require('nodemailer')

smtpConfig =
  service: "Mailjet"
  auth:
    user: mailConfig['mail_user']
    pass: mailConfig['mail_pass']

# create reusable transporter object using the default SMTP transport
transporter = nodemailer.createTransport(smtpConfig)
# setup e-mail data with unicode symbols
mailOptions =
  from: '"Saturn Server Network" <info@saturnserver.org>'
  to: 'jeroen.akkerman1@gmail.com'
  bcc: '"Saturn Server Network" <info@saturnserver.org>'
  subject: 'Password reset request'
  text: 'Hello world ?'
  html: '<b>Hello world ?</b>'
# send mail with defined transport object
transporter.sendMail mailOptions, (error, info) ->
  if error
    return console.log(error)
  console.log 'Message sent: ' + info.response

router.get '/', (req, res) ->
  res.render 'index'