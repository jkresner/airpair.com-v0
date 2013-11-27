moment  = require 'moment'
mailman = require '../mail/mailman'

module.exports = class DomainService
  mailman: mailman

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
    @model.findOne search, (e, r) ->
      if e then return callback e
      r = {} if r is null
      callback null, r

  create: (o, callback) =>
    new @model( o ).save callback

  delete: (id, callback) =>
    @model.findByIdAndRemove id, callback

  update: (id, data, callback) =>
    ups = _.clone data
    delete ups._id # so mongo doesn't complain
    @model.findByIdAndUpdate(id, ups).lean().exec (e, r) =>
      if e? then $log 'error', e
      if e then return callback e
      callback null, r

  # be sure that request.user is a user object
  newEvent: (request, evtName, evtData) =>
    usr = request.user
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

    # only notify if the request is claimed
    if !request.owner then return evt

    # do not notify for views
    # notify for anything an expert does
    #   'expert updated' not important, b/c it is the same as 'expert reviewed'
    # notify for anything a customer does
    importantEvents = ['expert reviewed', 'customer updated',
      'customer expert review' #, 'customer payed' TODO
    ]
    if evtName in importantEvents
        # send email to owner admin
        options = {
          templateName: 'importantRequestEvent'
          subject: "[#{request.owner}] '#{evtName}' triggered by #{byUser.name}"
          owner: request.owner # e.g. 'mi'
          request: request
          evtName: evtName
          user: byUser.name
          expertStatus: evtData && evtData.expertStatus
        }
        @mailman.sendEmailToOwner options, (e) ->
          if e then $log 'sendEmailToOwner importantRequestEvent error', e
    evt
