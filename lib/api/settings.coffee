CRUDApi = require './_crud'
SettingsSvc   = require './../services/settings'

class SettingsApi

  svc: new SettingsSvc()

  constructor: (app) ->
    app.get     "/api/settings", @detail
    app.post    "/api/settings", @create
    app.put     "/api/settings", @update

  detail: (req, res) =>
    @svc.getByUserId req.user._id, (r) -> res.send r

  create: (req, res) =>
    @svc.create req.user._id, req.body, (r) -> res.send r

  update: (req, res) =>
    $log 'api updating', req.user._id
    @svc.update req.user._id, req.body, (r) -> res.send r


module.exports = (app) -> new SettingsApi app, 'settings'