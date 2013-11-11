authz     = require './../identity/authz'
loggedIn  = authz.LoggedIn isApi:true
SettingsSvc   = require './../services/settings'

class SettingsApi

  svc: new SettingsSvc()

  constructor: (app) ->
    app.get     "/api/settings", loggedIn, @detail
    app.post    "/api/settings", loggedIn, @create
    app.put     "/api/settings", loggedIn, @update

  detail: (req, res, next) =>
    @svc.getByUserId req.user._id, (e, r) ->
      if e then return next e
      res.send r

  create: (req, res, next) =>
    @svc.create req.user._id, req.body, (e, r) ->
      if e then return next e
      res.send r

  update: (req, res, next) =>
    @svc.update req.user._id, req.body, (e, r) ->
      if e then return next e
      res.send r

module.exports = (app) -> new SettingsApi app, 'settings'
