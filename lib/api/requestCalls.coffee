authz     = require './../identity/authz'
admin = authz.Admin()
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

    req.checkBody('duration', 'Invalid duration').notEmpty().isInt()
    errors = req.validationErrors()
    if errors
      res.send errors, 400
    req.sanitize('duration').toInt()

    @svc.create req.user._id, req.params.requestId, req.body, (e, r) ->
      if e then return next e
      res.send r

  update: (req, res, next) =>

module.exports = (app) -> new RequestCallsApi app, 'requests'
