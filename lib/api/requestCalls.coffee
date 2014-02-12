authz                  = require './../identity/authz'
admin                  = authz.Admin()
loggedIn               = authz.LoggedIn isApi:true
CallsSvc               = require './../services/requestCalls'
formatValidationErrors = require '../util/formatValidationErrors'
cSend                  = require '../util/csend'
moment                 = require 'moment-timezone'

class RequestCallsApi  # Always passes back a full request object

  svc: new CallsSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}/calls/:permalink", loggedIn, @detail
    app.post    "/api/#{route}/:requestId/calls", admin, @validate, @create
    app.put     "/api/#{route}/:requestId/calls/:callId", admin, @validate, @update

  detail: (req, res, next) =>
    @svc.getByCallPermalink req.params.permalink, cSend(res, next)

  validate: (req, res, next) ->
    req.checkBody('duration', 'Invalid duration').notEmpty().isInt()
    req.checkBody('date', 'Invalid date').notEmpty().is(/^\d\d \w\w\w \d\d\d\d$/)
    req.checkBody('time', 'Invalid time').notEmpty().is(/^\d\d:\d\d$/)
    errors = req.validationErrors()
    if errors
      return res.send formatValidationErrors(errors), 400
    req.sanitize('duration').toInt()

    {date, time} = req.body
    req.body.datetime = moment("#{date} #{time}").tz('America/Los_Angeles').toDate()
    if isNaN(req.body.datetime.getTime())
      return res.send data: date: 'Invalid Date', 400

    delete req.body.date
    delete req.body.time
    next()

  create: (req, res, next) =>
    # TODO also send 400 errors when google API has problems.
    @svc.create req.user._id, req.params.requestId, req.body, (e, results) ->
      if e && e.message.indexOf('Not enough hours') == 0
        errors = duration: e.message
        return res.send data: errors, 400
      if e then return next e
      res.send results.request

  # this sends back down only the changed call
  update: (req, res, next) =>
    # TODO also send 400 errors when google API has problems.
    @svc.update req.user._id, req.params.requestId, req.body, (e, call) ->
      if e && e.message.indexOf('Not enough hours') == 0
        errors = duration: e.message
        return res.send data: errors, 400
      if e then return next e
      res.send call

module.exports = (app) -> new RequestCallsApi app, 'requests'
