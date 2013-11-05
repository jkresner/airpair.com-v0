moment = require 'moment'

module.exports = class DomainService


  # Used to dump full list of customers
  getAll: (callback) ->
    @model.find {}, (e, r) ->
      r = {} if r is null
      callback r


  getById: (id, callback) =>
    @model.findOne { _id: id }, (e, r) => callback r


  getByUserId: (id, callback) =>
    @model.find userId: id, (e, r) -> callback r

  search: (search, callback) =>
    @model.find search, (e, r) -> callback r

  searchOne: (search, callback) =>
    @model.findOne search, (e, r) ->
      r = {} if r is null
      callback r

  create: (o, callback) =>
    new @model( o ).save callback

  delete: (id, callback) =>
    @model.findByIdAndRemove id, (e, r) => callback r

  update: (id, data, callback) =>
    ups = _.clone data
    delete ups._id # so mongo doesn't complain
    @model.findByIdAndUpdate(id, ups).lean().exec (e, r) =>
      if e? then $log 'error', e
      callback r


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
