CRUDApi     = require './_crud'
RequestsSvc = require './../services/requests'
# RatesSvc        = require './../services/rates'
authz       = require './../identity/authz'
admin       = authz.Admin isApi: true
loggedIn    = authz.LoggedIn isApi: true
Roles       = authz.Roles

class RequestApi extends CRUDApi

  model: require './../models/request'
  svc: new RequestsSvc()
  # rates: new RatesSvc()

  constructor: (app, route) ->
    app.get  "/api/admin/#{route}", admin, @admin
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
    @svc.getAll (r) -> res.send r


  inactive: (req, res, next) =>
    @svc.getInactive (r) -> res.send r


  list: (req, res) =>
    @svc.getByUserId req.user._id, (r) -> res.send r

  detail: (req, res) =>
    user = req.user
    @svc.getByIdSmart req.params.id, user, (r) =>
      if r? then res.send r else res.send(400, {})

  create: (req, res) =>
    @svc.create req.user, req.body, (r) -> res.send r

  update: (req, res) =>
    usr = req.user
    search = _id: req.params.id
    evts = []

    @model.findOne search, (e, r) =>

      # stop users updating other users requests (need a better solution!)
      if !(Roles.isAdmin(usr, r) || Roles.isRequestOwner(usr, r))
        return res.send 403

      data = _.clone req.body
      delete data._id # so mongo doesn't complain

      if data.status is "holding"
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

      @svc.update req.params.id, data, (r) => res.send r


  updateSuggestion: (req, res) =>
    usr = req.user
    @model.findOne { _id: req.params.id }, (e, r) =>
      if Roles.isRequestOwner(usr, r)
        @updateSuggestionByCustomer(req, res, r)
      else if Roles.isRequestExpert(usr, r) || Roles.isAdmin(usr)
        @svc.updateSuggestionByExpert r, usr, req.body, (r) => res.send r
      else
        res.send 403


  updateSuggestionByCustomer: (req, res, r) =>
    ups = req.body
    data = { suggested: r.suggested, events: r.events }
    sug = _.find r.suggested, (s) ->
      _.idsEqual s.expert.userId, ups.expert.userId
    sug.events.push @newEvent(req, "customer updated")
    sug.customerRating = ups.customerRating
    sug.customerFeedback = ups.customerFeedback
    if ups.expertStatus? then sug.expertStatus = ups.expertStatus
    data.events.push @newEvent req, "customer expert review", ups

    @svc.update req.params.id, data, (r) => res.send r


module.exports = (app) -> new RequestApi app,'requests'
