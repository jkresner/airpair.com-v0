moment   = require 'moment'
authz    = require './../identity/authz'

class Api


  logging: off    # note: can set logging in the child class


  constructor: (app, route) ->
    @admin    = authz.Admin isApi: true
    @loggedIn = authz.LoggedIn isApi: true
    @routes app, route


  routes: (app, routes) ->
    $log 'override in child class'


  utcNow: ->
    new moment().utc().toJSON()


  cSend: (res, next) ->
    (e, r) ->
      if @logging then $log 'cSend', e, r
      if e && e.status then return res.send(400, e) # backbone will render errors
      if e then return next e
      res.send r


  getFieldError: (msg, attr, attrMsg) ->
    err = isServer: true, msg: msg + " failed", data: {}
    err.data[attr] = attrMsg
    err


  tFE: (res, msg, attr, attrMsg) ->
    res.contentType('application/json')
    res.send 400, @getFieldError(msg, attr, attrMsg)




module.exports = Api
