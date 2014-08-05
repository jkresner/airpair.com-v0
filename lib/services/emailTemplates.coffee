DomainService = require './_svc'

module.exports = class EmailTemplates extends DomainService

  model: require './../models/emailTemplate'

  constructor: (user) ->
    super user

  createOrUpdate: (data, callback) ->
    @searchOne {slug: data.slug}, {}, (err, template) =>
      if template?
        @update template._id, data, callback
      else
        @create data, callback

