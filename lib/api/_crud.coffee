und = require 'underscore'
authz = require './../auth/ensureLoggedInForApi'
moment = require 'moment'

class CRUDApi

  logging: off    # note: can set logging in the child class

  constructor: (app, route) ->
    app.get     "/api/#{route}", authz(), @list
    app.get     "/api/#{route}/:id", authz(), @detail
    app.post    "/api/#{route}", authz(), @create
    app.put     "/api/#{route}/:id", authz(), @update
    app.delete  "/api/#{route}/:id", authz(), @delete

###############################################################################
## Data loading / clearing (should only be used when necessary)
###############################################################################

  # clear: -> @model.find({}).remove()

###############################################################################
## Standard CRUD
###############################################################################

  detail: (req, res) =>
    @model.findOne { _id: req.params.id }, (e, r) =>
      if @logging then $log 'detail:', e, r
      res.send r


  list: (req, res) =>
    @model.find (e, r) -> res.send r


  create: (req, res) =>
    new @model( req.body ).save (e, r) =>
      if @logging then $log 'created:', e, r
      res.send r


  update: (req, res) =>
    data = und.clone req.body
    delete data._id # so mongo doesn't complain
    @model.findByIdAndUpdate req.params.id, data, (e, r) =>
      if @logging then $log 'updated:', e, r
      res.send r


  delete: (req, res) =>
    @model.find( _id: req.params.id ).remove (e, r) ->
    if @logging then $log 'deleted:', e, r
    res.send r


  utcNow: ->
    new moment().utc().toJSON()


module.exports = CRUDApi