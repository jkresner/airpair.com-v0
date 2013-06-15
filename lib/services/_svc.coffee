moment = require 'moment'

module.exports = class DomainService


  # Used to dump full list of customers
  getAll: (callback) ->
    @model.find {}, (e, r) ->
      r = {} if r is null
      callback r


  getByUserId: (id, callback) =>
    @model.find userId: id, (e, r) -> callback r


  getById: (id, callback) =>
    @model.findOne { _id: id }, (e, r) => callback r


  newEvent: (user, evtName, evtData) ->
    byUser = 'anon'
    if user?
      byUser =
        id: user._id
        name: user.google.displayName

    evt =
      utc:  new moment().utc().toJSON()
      name: evtName
      by:   byUser

    if evtData? then evt.data = evtData

    evt
