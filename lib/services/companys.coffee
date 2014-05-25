DomainService   = require './_svc'

module.exports = class CompanysService extends DomainService

  model: require './../models/company'

  getById: (id, cb) ->

    query = if id is 'me' then 'contacts.userId': @user._id else _id: id

    @svc.searchOne query, null, cb
