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
    req.checkBody('date', 'Invald date').notEmpty().isDate()
    req.checkBody('time', 'Invalid time').notEmpty().is(/^\d\d:\d\d$/)
    errors = req.validationErrors()
    if errors
      return res.send errors, 400
    req.sanitize('duration').toInt()

    {date, time} = req.body
    req.body.datetime = new Date "#{date} #{time} PST"
    req.body.date = undefined
    req.body.time = undefined

    console.log 'create', JSON.stringify req.body, null, 2
    @svc.create req.user._id, req.params.requestId, req.body, (e, r) ->
      if e then return next e
      res.send r

  update: (req, res, next) =>

module.exports = (app) -> new RequestCallsApi app, 'requests'
