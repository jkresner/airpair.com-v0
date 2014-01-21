authz     = require './../identity/authz'
admin = authz.Admin()
loggedIn  = authz.LoggedIn isApi:true
CallsSvc   = require './../services/requestCalls'
formatValidationErrors = require '../util/formatValidationErrors'
cSend = require '../util/csend'

class RequestCallsApi  # Always passes back a full request object

  svc: new CallsSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}/calls/:permalink", loggedIn, @detail
    app.post    "/api/#{route}/:requestId/calls", admin, @create
    # app.put     "/api/#{route}/:requestId/calls/:callId", admin, @update

  detail: (req, res, next) =>
    @svc.getByCallPermalink req.params.permalink, cSend(res, next)

  create: (req, res, next) =>
    req.checkBody('duration', 'Invalid duration').notEmpty().isInt()
    req.checkBody('date', 'Invalid date').notEmpty().isDate()
    req.checkBody('time', 'Invalid time').notEmpty().is(/^\d\d:\d\d$/)
    errors = req.validationErrors()
    if errors
      return res.send formatValidationErrors(errors), 400
    req.sanitize('duration').toInt()

    {date, time} = req.body
    req.body.datetime = new Date "#{date} #{time} PST"
    delete req.body.date
    delete req.body.time

    @svc.create req.user._id, req.params.requestId, req.body, (e, results) ->
      if e && e.message.indexOf('Not enough hours') == 0
        errors =
          duration: 'Please order more hours in order to schedule more'
        return res.send data: errors, 400
      if e then return next e
      res.send results.request

  # update: (req, res, next) =>
  #   console.log 'got got got'
  #   req.checkBody('duration', 'Invalid duration').notEmpty().isInt()
  #   req.checkBody('date', 'Invalid date').notEmpty().isDate()
  #   req.checkBody('time', 'Invalid time').notEmpty().is(/^\d\d:\d\d$/)
  #   errors = req.validationErrors()
  #   if errors
  #     return res.send errors, 400
  #   req.sanitize('duration').toInt()

  #   {date, time} = req.body
  #   req.body.datetime = new Date "#{date} #{time} PST"
  #   req.body.date = undefined
  #   req.body.time = undefined

  #   console.log "update, #{req.params.callId}", JSON.stringify req.body, null, 2
  #   @svc.update req.user._id, req.params.requestId, req.body, (e, r) ->
  #     if e then return next e
  #     res.send r

module.exports = (app) -> new RequestCallsApi app, 'requests'
