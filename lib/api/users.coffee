
class UserApi extends require('./_api')

  Svc:  ->

  routes: (app, route) ->
    app.get   "/api/#{route}/me", @ap, @detail


  detail: (req, res) =>
    VDSvc = require('../services/_viewdata')
    res.send new VDSvc(req.user).session()


module.exports = (app) -> new UserApi app, 'users'
