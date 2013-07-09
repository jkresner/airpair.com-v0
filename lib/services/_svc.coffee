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


  create: (o, callback) =>
    new @model( o ).save (e, r) => callback r


  update: (id, data, callback) =>
    @model.findByIdAndUpdate(id, data).lean().exec (e, r) => callback r


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
