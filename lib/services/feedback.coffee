DomainService = require './_svc'
Mailman = require '../mail/mailman'

module.exports = class EmailTemplates extends DomainService

  mailman: Mailman

  constructor: (user) ->
    super user

  sendMail: (data, page, callback) ->
    options =
      templateName: 'feedback'
      subject: 'Customer Feedback from airpair.com'
      message: data.message
      email: if @usr? then @usr.google._json.email else 'anonymous'
      page: page
      to: 'team@airpair.com'

    @mailman.sendEmail options, callback
