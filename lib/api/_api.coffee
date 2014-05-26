moment   = require 'moment'
authz    = require './../identity/authz'

class Api


  logging: off    # note: can set logging in the child class


  constructor: (app, route) ->
    @admin    = authz.Admin isApi: true
    @loggedIn = authz.LoggedIn isApi: true
    @routes app, route


  """ middleware for all airpair api calls """
  ap: (req, res, next) =>
    @svc = new @Svc req.user
    @cbSend = @cSend res, next
    @data = _.clone req.body
    @data._id # so mongo doesn't complain
    next()

  routes: (app, route) ->
    $log 'override in child class'

  # default http operations
  list: (req) => @svc.getAll @cbSend
  create: (req) => @svc.create @data, @cbSend
  detail: (req) => @svc.getById req.params.id, @cbSend
  update: (req) => @svc.update req.params.id, @data, @cbSend
  delete: (req) => @svc.delete req.params.id, @cbSend

  utcNow: -> new moment().utc().toJSON()


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
