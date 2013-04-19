und = require 'underscore'
authz = require './../auth/ensureLoggedInForApi'
moment = require 'moment'

class CRUDApi

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
    @model.findOne { _id: req.params.id }, (e, r) -> res.send r


  list: (req, res) =>
    @model.find (e, r) -> res.send r


  create: (req, res) =>
    @model( req.body ).save (e, r) -> res.send r


  update: (req, res) =>
    data = und.clone req.body
    delete data._id # so mongo doesn't complain
    @model.findByIdAndUpdate req.params.id, data, (e, r) -> res.send r


  delete: (req, res) =>
    @model.find( _id: req.params.id ).remove (e, r) -> res.send r

  utcNow: ->
    new moment().utc().toJSON()

module.exports = CRUDApi