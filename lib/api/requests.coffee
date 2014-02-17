CRUDApi     = require './_crud'
RequestsSvc = require './../services/requests'
authz       = require './../identity/authz'
admin       = authz.Admin isApi: true
loggedIn    = authz.LoggedIn isApi: true
Roles       = authz.Roles
cSend       = require '../util/csend'

class RequestApi extends CRUDApi

  model:    require '../models/request'
  svc:      new RequestsSvc()

  constructor: (app, route) ->
    app.get  "/api/admin/#{route}", admin, @admin
    app.get  "/api/admin/#{route}/active", admin, @active
    app.get  "/api/admin/#{route}/inactive", admin, @inactive
    app.put  "/api/#{route}/:id/suggestion", loggedIn, @updateSuggestion
    app.get  "/api/#{route}/:id", @detail
    super app, route


###############################################################################
## CRUD extensions
###############################################################################

  ## Temporary
  newEvent: (req, evtName, evtData) ->
    @svc.newEvent req.user, evtName, evtData


  admin: (req, res, next) =>
    @svc.getAll cSend(res, next)

  active: (req, res, next) =>
    @svc.getActive cSend(res, next)

  inactive: (req, res, next) =>
    @svc.getInactive cSend(res, next)


  list: (req, res, next) =>
    @svc.getByUserId req.user._id, cSend(res, next)


  detail: (req, res, next) =>
    user = req.user
    @svc.getByIdSmart req.params.id, user, (e, r) =>
      if e then return next e
      if r? then res.send r else res.send(400, {})


  create: (req, res, next) =>
    @svc.create req.user, req.body, cSend(res, next)


  update: (req, res, next) =>
    usr = req.user
    search = _id: req.params.id
    evts = []

    @model.findOne search, (e, r) =>
      if e then return next e

      # stop users updating other users requests (need a better solution!)
      if !(Roles.isAdmin(usr, r) || Roles.isRequestOwner(usr, r))
        return res.send 403

      data = _.clone req.body
      delete data._id # so mongo doesn't complain

      if data.status is "holding" && (!data.owner?||data.owner=='')
        evts.push @newEvent req, "send received email"
        data.owner = Roles.getAdminInitials usr.google.id

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

          # make sure our suggested rate is less than our budget!
          # s.suggestedRate = @rates.calcSuggestedRate r, s.expert

          s.expertStatus = "waiting"
          s.events = [ @newEvent(req, "first contacted") ]

      if r.suggested?
        for s in r.suggested
          match = _.find req.body.suggested, (sug) ->
            _.idsEqual sug._id, s._id
          if !match?
            evts.push @newEvent(req, "removed suggested #{s.expert.username}")

      if evts.length is 0
        evts.push @newEvent req, "updated"

      data.events.push.apply(data.events, evts)

      @svc.update req.params.id, data, (e, r) =>
        if e then return next e
        # if Roles.isRequestOwner(usr, r) && r.status != 'received'
        #   @mailman.importantRequestEvent "customer updated", usr, r
        res.send r


  updateSuggestion: (req, res, next) =>
    usr = req.user
    @model.findOne { _id: req.params.id }, (e, r) =>
      if e then return next e
      if Roles.isRequestOwner(usr, r)
        return next new Error('Customer update suggestion not implemented')
        #@updateSuggestionByCustomer(req, res, next, r)
      else if Roles.isRequestExpert(usr, r)
        @svc.updateSuggestionByExpert r, usr, req.body, cSend(res, next)
      else
        res.send 403

module.exports = (app) -> new RequestApi app, 'requests'
