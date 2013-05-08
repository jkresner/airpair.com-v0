users = require './../data/users'

data = users: []
data.users.admin = users[0]
data.users.jk = users[1]

module.exports =

  initialize: ->

    # default to admin
    global.session = data.users.admin

    (req, res, next) ->
      passport = @
      passport._key = 'passport'
      passport._userProperty = 'user'
      passport.serializeUser = (user, done) -> done null, user
      passport.deserializeUser = (user, done) -> done null, global.session

      req._passport = instance: passport

      req._passport.session = user: session

      next()

  setSession: (userKey) ->
    if data.users[userKey]?
      global.session = data.users[userKey]
    else
      global.session = data.users.admin