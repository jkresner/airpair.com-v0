authz     = require './../identity/authz'
loggedIn  = authz.LoggedIn isApi:true
SettingsSvc   = require './../services/settings'

class SettingsApi

  svc: new SettingsSvc()

  constructor: (app) ->
    app.get     "/api/settings", loggedIn, @detail
    app.post    "/api/settings", loggedIn, @create
    app.put     "/api/settings", loggedIn, @update

  detail: (req, res) =>
    @svc.getByUserId req.user._id, (r) -> res.send r

  create: (req, res) =>
    @svc.create req.user._id, req.body, (r) -> res.send r

  update: (req, res) =>
    @svc.update req.user._id, req.body, (r) -> res.send r


module.exports = (app) -> new SettingsApi app, 'settings'