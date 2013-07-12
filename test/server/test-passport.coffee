users = require './../data/users'

data = users: []
data.users.anon = authenticated: false
data.users.admin = users[0]  # jk@airpair.com
data.users.jk = users[1]  # jkresner@gmail.com
data.users.jk2 = users[2]  # jk@airpair.co
data.users.artjumble = users[5] # Steven Matthews
data.users.bearMountain = users[4] # Jeffrey Camealy
data.users.emilLee = users[6] # Emil Lee
data.users.richkuo = users[7] # Richard Kuo
data.users.mattvanhorn = users[8] # Matthew Van Horn
data.users.reQunix = users[9] # Michael Prins

setSession = (userKey) ->
  if data.users[userKey]?
    global.session = data.users[userKey]
  else
    global.session = data.users.admin


module.exports =

  setSession: setSession

  initialize: (app) ->

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

      app.get '/set-session/:id', (req, r) =>
        setSession req.params.id
        r.send { set: data.users[req.params.id] }

      next()
