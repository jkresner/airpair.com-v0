authz     = require './../identity/authz'
admin     = authz.Admin isApi: true
cSend     = require '../util/csend'

class UserApi

  model: require './../models/user'

  constructor: (app) ->
    app.get     "/api/users/me", @detail
    app.get     "/api/admin/users", admin, @adminlist

  detail: (req, res, next) =>

    if req.isAuthenticated()
      user = _.clone req.user
      if user.google then delete user.google.token
      if user.twitter then delete user.twitter.token
      if user.bitbucket then delete user.bitbucket.token
      if user.github then delete user.github.token
      if user.stack then delete user.stack.token
    else
      # not sure this will work right
      # user = false # tricks passport into thinking they are loggedout
      user = authenticated : false

    res.send user


  adminlist: (req, res, next) =>
    $log 'users.adminlist'
    @model.find {}, cSend(res, next)


module.exports = (app) -> new UserApi(app)
