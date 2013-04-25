CRUDApi = require './_crud'
Company = require './../models/company'
Expert = require './../models/expert'
und = require 'underscore'
auth = require './../auth/authz/authz'

class RequestApi extends CRUDApi

  model: require './../models/request'

  constructor: (app, route) ->
    app.get     "/api/admin/#{route}", auth.AdminApi(), @admin
    super app, route

###############################################################################
## CRUD extensions
###############################################################################

  admin: (req, res) =>
    @model.find {}, (e, r) ->
      r = {} if r is null
      res.send r

  list: (req, res) =>
    search = userId: req.user._id
    @model.find search, (e, r) ->
      r = {} if r is null
      res.send r

  detail: (req, res) =>
    @model.findOne { _id: req.params.id }, (e, r) =>
      res.send r

  create: (req, res) =>
    req.body.userId = req.user._id
    req.body.events = [{ name:'created', utc: @utcNow()}]
    req.body.status = 'received'

    new @model( req.body ).save (e, r) -> res.send r

  update: (req, res) =>
    # stop users updating other users requests (need a better solution!)
    if req.body.userId = req.user._id then return res.send 403

    # @getDevs req, =>
    data = und.clone req.body
    delete data._id # so mongo doesn't complain
    @model.update { _id: req.params.id }, data, (e, r) -> res.send req.body

  # getDevs: (req, callback) =>
  #   if ! req.body.suggested? then return callback()

  #   devs = und.pluck req.body.suggested, 'dev'
  #   devIds = und.pluck devs, '_id'
  #   Dev.find().where('_id').in(devIds).exec (er, re) =>
  #     console.log 're', re,
  #     console.log 'req.body.suggested', req.body.suggested
  #     for s in req.body.suggested
  #       console.log 's.devsv', s.dev
  #       s.dev = und.find( re, (d) -> console.log 'd',d; d._id.toString() == s.dev._id )
  #     console.log 'req.body.suggested', req.body.suggested
  #     callback()


module.exports = (app) -> new RequestApi app,'requests'