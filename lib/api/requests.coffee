CRUDApi = require './_crud'
Company = require './../models/company'
Expert = require './../models/expert'
und = require 'underscore'
auth = require './../auth/authz/authz'
role = auth.Roles


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
      if !r? then return res.send(400)
      if role.isAdmin(req) || role.isRequestOwner(req, r) || role.isRequestExpert(req, r)
        res.send r
      else
        res.send(400)


  create: (req, res) =>
    req.body.userId = req.user._id
    req.body.events = [{ name:'created', utc: @utcNow()}]
    req.body.status = 'received'
    new @model( req.body ).save (e, r) -> res.send r


  update: (req, res) =>
    search = _id: req.params.id
    @model.find search, (e, r) =>

      # stop users updating other users requests (need a better solution!)
      if !(role.isAdmin(req) || role.isRequestOwner(req, r))
        return res.send 403

      data = und.clone req.body
      delete data._id # so mongo doesn't complain

      if data.status is "canceled" && !data.canceledDetail
        return @tFE res, 'Update', 'canceledDetail', 'Must supply canceled reason'
      else if r.status != "canceled" && data.status is "canceled"
        data.events.push @newEvent(req, "canceled")

      if data.status is "incomplete" && !data.incompleteDetail
        return @tFE res, 'Update', 'incompleteDetail', 'Must supply incomplete reason'
      else if r.status != "incomplete" && data.status is "incomplete"
        data.events.push @newEvent(req, "incomplete")

      for s in req.body.suggested
        if !s.events?
          data.status = "review"
          reqEvt = @newEvent(req, "suggested #{s.expert.username}")
          data.events.push reqEvt

          s.expertStatus = "waiting"
          s.events = [ @newEvent(req, "created") ]

      @model.findByIdAndUpdate req.params.id, data, (ee, rr) ->
        res.send rr



module.exports = (app) -> new RequestApi app,'requests'