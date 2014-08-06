DomainService = require './_svc'
Mailman = require '../mail/mailman'

module.exports = class EmailTemplates extends DomainService

  model: require './../models/emailTemplate'
  mailman: Mailman

  constructor: (user) ->
    super user

  createOrUpdate: (data, callback) ->
    @searchOne {slug: data.slug}, {}, (err, template) =>
      if template?
        @update template._id, data, callback
      else
        @create data, callback

  send: (slug, data, callback) ->
    @searchOne {slug: slug}, {}, (err, template) =>
      if template?
        options = _.extend(data, template)
        @mailman.sendEmail options, callback
      else
        callback(err, template)
