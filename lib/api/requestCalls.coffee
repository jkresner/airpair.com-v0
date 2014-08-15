formatValidationErrors = require '../util/formatValidationErrors'
moment                 = require 'moment-timezone'

# Always passes back a full request object
class RequestCallsApi extends require('./_api')

  Svc: require './../services/requestCalls'

  routes: (app) ->
    app.get     "/requests/calls/:permalink", @loggedIn, @ap, @detail
    app.get     "/admin/requests/calls/:sddmmyy/:eddmmyy", @admin, @ap, @getOnAir
    app.post    "/requests/:requestId/calls", @mm, @validate, @ap, @create
    app.put     "/requests/:requestId/calls/:callId", @mm, @validate, @ap, @update

  detail: (req) =>
    @svc.getByCallPermalink req.params.permalink, @cSend

  getOnAir: (req) =>
    start = moment req.params.sddmmyy, "YYYY-MM-DD"
    end = moment req.params.eddmmyy, "YYYY-MM-DD"
    @svc.getOnAir start, end, @cbSend

  validate: (req, res, next) ->
    req.checkBody('duration', 'Invalid duration').notEmpty().isInt()
    req.checkBody('date', 'Invalid date').notEmpty().is(/^\d\d \w\w\w \d\d\d\d$/)
    req.checkBody('time', 'Invalid time').notEmpty().is(/^\d\d:\d\d$/)
    errors = req.validationErrors()
    if errors
      return res.send formatValidationErrors(errors), 400
    req.sanitize('duration').toInt()

    {date, time} = req.body
    req.body.datetime = moment.tz("#{date} #{time}", 'America/Los_Angeles').toDate()
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
    @svc.update req.params.requestId, req.body, (e, call) ->
      if e && e.message.indexOf('Not enough hours') == 0
        errors = duration: e.message
        return res.send data: errors, 400
      if e then return next e
      res.send call


module.exports = (app) -> new RequestCallsApi(app)
