ViewDataService = require('../services/_viewdata')

class UserApi extends require('./_api')

  routes: (app, route) ->
    app.get "/api/#{route}/me", @ap, @detail


  detail: (req, res) =>
    res.send new ViewDataService(req.user).session true


module.exports = (app) -> new UserApi app, 'users'
