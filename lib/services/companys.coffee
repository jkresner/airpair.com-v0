DomainService   = require './_svc'

module.exports = class CompanysService extends DomainService

  model: require './../models/company'

  getById: (id, cb) ->

    query = if id is 'me' then 'contacts.userId': @usr._id else _id: id

    @searchOne query, null, cb
