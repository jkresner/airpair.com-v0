authz       = require './../identity/authz'
admin       = authz.Admin isApi: true
loggedIn    = authz.LoggedIn isApi: true
moment = require 'moment'
errors = require './errors'

class CRUDApi

  logging: off    # note: can set logging in the child class

  constructor: (app, route) ->
    app.get     "/api/#{route}", loggedIn, @list
    app.get     "/api/#{route}/:id", loggedIn, @detail
    app.post    "/api/#{route}", loggedIn, @create
    app.put     "/api/#{route}/:id", loggedIn, @update
    app.delete  "/api/#{route}/:id", loggedIn, @delete

###############################################################################
## Data loading / clearing (should only be used when necessary)
###############################################################################

  # clear: -> @model.find({}).remove()

###############################################################################
## Standard CRUD
###############################################################################

  detail: (req, res, next) =>
    # $log 'CRUD.detail', req.user
    @model.findOne { _id: req.params.id }, (e, r) =>
      if @logging then $log 'detail:', e, r
      if e then return next e
      res.send r


  list: (req, res, next) =>
    @model.find (e, r) ->
      if e then return next e
      res.send r


  create: (req, res, next) =>
    # $log 'CRUD.create', req.body
    new @model( req.body ).save (e, r) =>
      if @logging then $log 'created:', e, r
      if e? then $log 'created.error:', e
      if e then return next e
      res.send r


  update: (req, res, next) =>
    data = _.clone req.body
    delete data._id # so mongo doesn't complain
    @model.findByIdAndUpdate req.params.id, data, (e, r) =>
      if @logging then $log 'updated:', e, r
      if e then return next e
      res.send r


  delete: (req, res, next) =>
    @model.find( _id: req.params.id ).remove (e, r) ->
      if @logging then $log 'deleted:', e, r
      if e then return next e
      res.send { status: 'deleted' }


  utcNow: ->
    new moment().utc().toJSON()


  tFE: (res, msg, attr, attrMsg) ->
    res.contentType('application/json')
    res.send 400, errors.getFieldError(msg, attr, attrMsg)


module.exports = CRUDApi
