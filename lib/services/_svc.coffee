moment = require 'moment'

module.exports = class DomainService

  logging: off


  constructor: (user) ->
    @usr = user


  searchMany: (query, opts, callback) =>
    opts = {} if !opts?
    {fields,options} = opts
    @model.find(query,fields,options).lean().exec (e, r) =>
      if e && @logging then $log 'svc.search.err', query, e
      callback e, r


  searchOne: (query, opts, callback) =>
    opts = {} if !opts?
    {fields,options} = opts
    @model.findOne(query,fields,opts).lean().exec (e, r) =>
      if e && @logging then $log 'svc.searchOne.err', query, e
      callback e, r

  getAll: (callback) => @searchMany({}, {}, callback)
  getByUserId: (userId, callback) => @searchMany {userId}, {}, callback
  getById: (id, callback) => @searchOne {_id: id}, {}, callback



  create: (o, callback) =>
    new @model( o ).save (e,r) =>
      if e && @logging then $log 'svc.create', o, e
      callback e, r

  delete: (id, callback) =>
    @model.findByIdAndRemove id, callback

  # TODO this breaks the paypal payout button b/c the redeemedCalls schema isn't
  # put in by mongoose
  update: (id, data, callback) =>
    ups = _.omit data, '_id' # so mongo doesn't complain
    @model.findByIdAndUpdate(id, ups).lean().exec (e, r) =>
      if e? && @logging then $log 'svc.update.error', e
      callback e, r


  # TODO: next time someone wants to change newEvent code, first refactor
  newEvent: (evtName, evtData) ->
    byUser = 'anon'
    if @usr? && (@usr.authenticated != false)
      byUser =
        id: @usr._id
        name: @usr.google.displayName

    evt =
      utc:  new moment().utc().toJSON()
      name: evtName
      by:   byUser

    if evtData? then evt.data = evtData

    evt


  unauthorized: (msg, callback) =>
    callback { status: 403, message: msg }
