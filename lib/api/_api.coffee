authz    = require './../identity/authz'

class Api
  # Accessor to backing Service object for this API
  # is overriden in child class
  Svc:  ->
  logging: off

  # set important authorization-related properties
  # and read routes handled by this Api object
  constructor: (app) ->
    @admin    = authz.Admin isApi: true
    @mm       = authz.Matchmaker isApi: true
    @loggedIn = authz.LoggedIn isApi: true
    @routes app

  # Standardized middleware routine
  ap: (req, res, next) =>
    # Instantiate backing service (similar to controller)
    @svc = new @Svc req.user

    # Assign the final callback function that ends the chain
    @cbSend = @cSend res, next

    # Grab params and assign them to @data
    @data = _.clone req.body

    # todo: what is this? why needed
    @data._id # so mongo doesn't complain

    # dump info about the request if logging is on
    if @logging
      console.log "\n\n ----------------- NEW API REQUEST #{req.originalUrl} -------------------"
      console.log req.headers, "PARAMS -------------------", @data
      console.log "------------------------------------------------------------------------\n\n"

    # finally, call next callback in the middleware chain
    next()

  routes: (app) ->
    $log 'override in child class'

  # default http operations
  list: (req) => @svc.getAll @cbSend
  create: (req) => @svc.create @data, @cbSend
  detail: (req) => @svc.getById req.params.id, @cbSend
  update: (req) => @svc.update req.params.id, @data, @cbSend
  delete: (req) => @svc.delete req.params.id, @cbSend

  # ----- Convenience Callbacks ------- #
  sendResults: (results) =>
    if @logging then $log 'sendResults', results
    @cbSend(null, results)

  sendError: (err) =>
    if @logging then $log 'sendError', err
    @cbSend(err)

  # ----- Technical Callbacks --------- #
  cSend: (res, next) ->
    (e, r) =>
      if @logging then $log 'cSend', e, r
      if e && e.status then return res.send(400, e) # backbone will render errors
      if e then return next e
      res.send r

  dSend: (res, next) ->
    (e, r) =>
      if @logging then $log 'dSend', e, r
      if e && e.status then return res.send(400, e) # backbone will render errors
      if e then return next e
      res.send status: 'deleted'

  tFE: (res, msg, attr, attrMsg) ->
    res.contentType('application/json')
    res.send 400, @getFieldError(msg, attr, attrMsg)

  getFieldError: (msg, attr, attrMsg) ->
    err = isServer: true, msg: msg + " failed", data: {}
    err.data[attr] = attrMsg.toString()
    err

module.exports = Api
