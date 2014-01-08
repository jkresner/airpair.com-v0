authz            = require './../identity/authz'
loggedIn         = authz.LoggedIn isApi:true
admin            = authz.Admin isApi: true
SettingsSvc      = require './../services/settings'


class SettingsApi

  #DT what do you think cSend ("Check Send")... so much less code :)
  cSend: (res, next) ->
    (e, r) ->
      if e then return next e
      res.send r

  svc: new SettingsSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}", loggedIn, @detail
    app.post    "/api/#{route}", loggedIn, @create
    app.put     "/api/#{route}", loggedIn, @update


  detail: (req, res, next) =>
    @svc.getByUserId req.user._id, @cSend(res,next)

  create: (req, res, next) =>
    @svc.create req.user._id, req.body, @cSend(res,next)

  update: (req, res, next) =>
    @svc.update req.body, @cSend(res,next)


module.exports = (app) -> new SettingsApi app, 'settings'
