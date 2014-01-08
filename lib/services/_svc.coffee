
moment = require 'moment'

module.exports = class DomainService


  # Used to dump full list of customers
  getAll: (callback) ->
    @model.find {}, (e, r) ->
      if e then return callback e
      r = {} if r is null
      callback null, r


  getById: (id, callback) =>
    @model.findOne { _id: id }, callback


  getByUserId: (id, callback) =>
    @model.find userId: id, callback

  search: (search, callback) =>
    @model.find search, callback

  searchOne: (search, callback) =>
    @model.findOne(search).lean().exec (e, r) =>
      if e then return callback e
      r = {} if r is null
      callback null, r

  create: (o, callback) =>
    new @model( o ).save callback

  delete: (id, callback) =>
    @model.findByIdAndRemove id, callback

  update: (id, data, callback) =>
    ups = _.omit data, '_id' # so mongo doesn't complain
    @model.findByIdAndUpdate(id, ups).lean().exec (e, r) =>
      if e?
        $log 'update.error', e
        return callback e
      callback null, r


  # TODO: next time someone wants to change newEvent code, first refactor
  # TODO when refactoring have a separate collection for all of them
  newEvent: (usr, evtName, evtData) ->
    byUser = 'anon'
    if usr? && (usr.authenticated != false)
      byUser =
        id: usr._id
        name: usr.google.displayName

    evt =
      utc:  new moment().utc().toJSON()
      name: evtName
      by:   byUser

    if evtData? then evt.data = evtData

    evt
