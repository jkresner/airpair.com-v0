
class UserApi extends require('./_api')

  routes: (app) ->
    app.get     "/api/users/me", @ap, @detail


  detail: (req, res, next) =>
    res.send new require('../../_viewdata')(req.user).session()


module.exports = (app) -> new UserApi(app)
