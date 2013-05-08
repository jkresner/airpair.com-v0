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
    # app.put  "/api/#{route}/suggestion", auth.LoggedInApi(), @updateSuggestionByExpert
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
      sug = und.find r.suggested, (s) -> s.expert.userId == evt.by.id
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

          match = und.find req.body.suggested, (sug) -> sug._id == s._id
          if !match?
            evts.push @newEvent(req, "removed suggested #{s.expert.username}")

      if evts.length is 0
        evts.push @newEvent req, "updated"

      data.events.push.apply(data.events, evts)

      @model.findByIdAndUpdate req.params.id, data, (ee, rr) ->
        res.send rr


  # updateSuggestionByExpert: (req, res) =>
  #   ups = req.body
  #   @model.findOne { _id: rid }, (e, r) =>
  #     if role.isRequestExpert(req, r) || role.isAdmin(req)
  #       data = { suggested: r.suggested }
  #       sug = und.find r.suggested, (s) -> s.expert.userId == evt.by.id
  #       sug.events.push @newEvent(req, "expert updated")
  #       sug.expertStatus = ups.expertStatus
  #       sug.expertFeedback = ups.expertFeedback
  #       sug.expertRating = ups.expertRating
  #       sug.expertComment = ups.expertComment
  #       sug.expertAvailability = ups.expertAvailability

  #       @model.findByIdAndUpdate req.params.id, data, (ee, rr) ->
  #         res.send rr
  #     else
  #       res.send 403


module.exports = (app) -> new RequestApi app,'requests'