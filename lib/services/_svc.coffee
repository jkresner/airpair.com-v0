moment = require 'moment'

module.exports = class DomainService

  logging: off


  constructor: (user) ->
    @usr = user

  searchMany: (query, opts, cb) =>
    opts = {} if !opts?
    {fields,options} = opts
    @model.find(query,fields,options).lean().exec (e, r) =>
      if e && @logging then $log 'svc.search.err', query, e
      cb e, r

  searchManyPopulate: (query, opts, reference, cb) =>
    opts = {} if !opts?
    {fields,options} = opts
    @model.find(query,fields,options).populate(reference).lean().exec (e, r) =>
      if e && @logging then $log 'svc.search.err', query, e
      cb e, r

  searchOne: (query, opts, cb) =>
    opts = {} if !opts?
    {fields,options} = opts
    @model.findOne(query,fields,options).lean().exec (e, r) =>
      if e && @logging then $log 'svc.searchOne.err', query, e
      cb e, r

  getAll: (cb) => @searchMany {}, {}, cb
  getByUserId: (userId, cb) => @searchMany {userId}, {}, cb
  getById: (id, cb) => @searchOne {_id: id}, {}, cb


  create: (o, cb) =>
    new @model( o ).save (e,r) =>
      if e && @logging then $log 'svc.create', o, e
      cb e, r

  delete: (id, cb) =>
    @model.findByIdAndRemove id, cb


  update: (id, data, cb) =>
    ups = _.omit data, '_id' # so mongo doesn't complain
    @model.findByIdAndUpdate(id, ups).lean().exec (e, r) =>
      if e? && @logging then $log 'svc.update.error', e
      cb e, r


  # TODO: next time someone wants to change newEvent code, first refactor
  newEvent: (evtName, evtData) ->
    byUser = 'anon'
    if @usr? && (@usr.authenticated != false)
      byUser = id: @usr._id
      byUser.name = @usr.google.displayName if @usr.google

    evt =
      utc:  new moment().utc().toJSON()
      name: evtName
      by:   byUser

    if evtData? then evt.data = evtData

    evt


  unauthorized: (msg, cb) =>
    cb { status: 403, message: msg }
