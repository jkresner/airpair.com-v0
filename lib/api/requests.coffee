CRUDApi = require './_crud'
Company = require './../models/company'
Expert = require './../models/expert'
und = require 'underscore'
auth = require './../auth/authz/authz'
role = auth.Roles


class RequestApi extends CRUDApi

  model: require './../models/request'

  constructor: (app, route) ->
    app.get  "/api/admin/#{route}", auth.AdminApi(), @admin
    app.put  "/api/#{route}/:id/suggestion", auth.LoggedInApi(), @updateSuggestion
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


  addViewEvent: (req, res, r, evt) =>
    up = { events: und.clone r.events }
    up.events.push evt
    if evt.name is "expert view"
      up.suggested = r.suggested
      sug = und.find r.suggested, (s) -> und.objectIdsEqual s.expert.userId, evt.by.id
      sug.events.push @newEvent(req, "viewed")
    @model.findByIdAndUpdate r._id, up, (ee, rr) ->
      res.send rr


  detail: (req, res) =>
    rid = req.params.id
    @model.findOne { _id: rid }, (e, r) =>
      if !r?
        res.send(400)
      else if role.isRequestExpert req, r
        @addViewEvent req, res, r, @newEvent(req, "expert view")
      else if role.isRequestOwner req, r
        @addViewEvent req, res, r, @newEvent(req, "customer view")
      else if role.isAdmin req
        res.send r
      else
        res.send(400)


  create: (req, res) =>
    req.body.userId = req.user._id
    req.body.events = [@newEvent(req, "created")]
    req.body.status = 'received'
    new @model( req.body ).save (e, r) ->
      if e then $log 'e', e
      res.send r


  update: (req, res) =>
    search = _id: req.params.id
    evts = []

    @model.findOne search, (e, r) =>

      # stop users updating other users requests (need a better solution!)
      if !(role.isAdmin(req) || role.isRequestOwner(req, r))
        return res.send 403

      data = und.clone req.body
      delete data._id # so mongo doesn't complain

      if data.status is "canceled" && !data.canceledDetail
        return @tFE res, 'Update', 'canceledDetail', 'Must supply canceled reason'
      else if r.status != "canceled" && data.status is "canceled"
        evts.push @newEvent req, "canceled"

      if data.status is "incomplete" && !data.incompleteDetail
        return @tFE res, 'Update', 'incompleteDetail', 'Must supply incomplete reason'
      else if r.status != "incomplete" && data.status is "incomplete"
        evts.push @newEvent req, "incomplete"

      for s in req.body.suggested

        if !s.events?
          data.status = "review"
          reqEvt = @newEvent(req, "suggested #{s.expert.username}")
          evts.push reqEvt

          s.expertStatus = "waiting"
          s.events = [ @newEvent(req, "first contacted") ]

      if r.suggested?
        for s in r.suggested
          match = und.find req.body.suggested, (sug) ->
            und.objectIdsEqual sug._id, s._id
          if !match?
            $log 'pushing removed', s._id, match
            evts.push @newEvent(req, "removed suggested #{s.expert.username}")

      if evts.length is 0
        evts.push @newEvent req, "updated"

      data.events.push.apply(data.events, evts)

      @model.findByIdAndUpdate req.params.id, data, (ee, rr) ->
        res.send rr


  updateSuggestion: (req, res) =>
    userId = req.user._id
    @model.findOne { _id: req.params.id }, (e, r) =>
      if role.isRequestOwner(req, r)
        @updateSuggestionByCustomer(req, res, r)
      else if role.isRequestExpert(req, r) || role.isAdmin(req)
        @updateSuggestionByExpert(req, res, r)
      else
        res.send 403


  # TODO, add some validation!!
  updateSuggestionByExpert: (req, res, r) =>
    ups = req.body
    data = { suggested: r.suggested, events: r.events }
    sug = und.find r.suggested, (s) -> und.idsEqual s.expert.userId, req.user._id
    sug.events.push @newEvent(req, "expert updated")
    sug.expertRating = ups.expertRating
    sug.expertFeedback = ups.expertFeedback
    sug.expertComment = ups.expertComment
    sug.expertStatus = ups.expertStatus
    sug.expertAvailability = ups.expertAvailability

    data.events.push @newEvent req, "expert reviewed", ups

    @model.findByIdAndUpdate req.params.id, data, (ee, rr) ->
      res.send rr


  updateSuggestionByCustomer: (req, res, r) =>
    ups = req.body
    data = { suggested: r.suggested, events: r.events }
    sug = und.find r.suggested, (s) -> und.idsEqual s.expert.userId, ups.expert.userId
    sug.customerRating = ups.customerRating
    sug.customerFeedback = ups.customerFeedback
    if ups.expertStatus? then sug.expertStatus = ups.expertStatus

    data.events.push @newEvent req, "customer expert review", ups

    @model.findByIdAndUpdate req.params.id, data, (ee, rr) ->
      res.send rr


module.exports = (app) -> new RequestApi app,'requests'