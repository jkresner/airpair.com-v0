Api         = require './_api'


class SettingsApi extends Api

  Svc: require './../services/settings'

  routes: (app) ->
    app.get     "/settings", @loggedIn, @ap, @detail
    app.post    "/settings", @loggedIn, @ap, @create
    app.put     "/settings", @loggedIn, @ap, @update


  detail: (req, res) => @svc.getByUserId req.user._id, @cbSend
  create: (req, res) => @svc.create req.user._id, req.body, @cbSend
  update: (req, res) => @svc.update req.body, @cbSend


module.exports = (app) -> new SettingsApi(app)
