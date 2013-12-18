authz     = require './../identity/authz'
loggedIn  = authz.LoggedIn isApi:true
CallsSvc   = require './../services/requestCalls'


class RequestCallsApi  # Always passing back requests

  svc: new CallsSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}/calls/:permalink", loggedIn, @detail
    app.post    "/api/#{route}/:requestId/calls", admin, @create
    app.put     "/api/#{route}/:requestId/calls/:id", admin, @update

  detail: (req, res, next) =>
    @svc.getByCallPermalink req.params.permalink, (e, r) ->
      if e then return next e
      res.send r

  create: (req, res, next) =>
    @svc.create req.user._id, req.params.requestId, req.body, (e, r) ->
      if e then return next e
      res.send r

  update: (req, res, next) =>

module.exports = (app) -> new CallsApi app, 'request'
