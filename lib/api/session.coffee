ViewDataService = require('../services/_viewdata')

class SessionApi extends require('./_api')

  routes: (app, route) ->
    app.get "/api/session", @ap, @detail

  detail: (req, res) =>
    userData = new ViewDataService(req.user).session(true)
    res.send
      user: userData
      config:
        segmentioKey: config.analytics.segmentio.writeKey

module.exports = (app) -> new SessionApi app, 'session'
