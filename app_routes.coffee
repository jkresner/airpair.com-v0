authz = require './lib/identity/authz'
loggedIn = authz.LoggedIn()
admin = authz.Admin()

RSvc = require('./lib/services/requests')
rSvc = new RSvc()

util = require('./app/scripts/util')

file = (r, file) -> r.sendfile "./public/#{file}.html"
getSession = (req) ->
  if req.isAuthenticated()
    user = _.clone req.user
    if user.google then delete user.google.token
    if user.twitter then delete user.twitter.token
    if user.bitbucket then delete user.bitbucket.token
    if user.github then delete user.github.token
    if user.stack then delete user.stack.token
  else
    user = authenticated : false

  JSON.stringify(user)


module.exports = (app) ->

  # login / auth routes
  require('./lib/auth/base')(app)

  # pages
  app.get '/about', (req, r)-> file r, 'homepage'
  app.get '/login', (req, r)-> file r, 'login'
  app.get '/be-an-expert*', (req, r)-> file r, 'beexpert'
  app.get '/find-an-expert*', (req, r)-> file r, 'request'

  app.get '/', (req, r) ->
    if !req.isAuthenticated() then file r, 'homepage' else file r, 'dashboard'

  app.get '/dashboard*', loggedIn, (req, r)-> file r, 'dashboard'

  app.get '/review/:id', (req, r)->
    rSvc.getByIdSmart req.params.id, req.user, (d) =>
      # $log 'dd'
      $log 'd', d
      ts = if d? then util.tagsString(d.tags) else 'Not found'
      r.render 'review.html', { session: getSession(req), request: JSON.stringify(d), tagsString: ts }

  # admin pages
  app.get '/adm/tags*', loggedIn, admin, (req, r) -> file r, 'adm/tags'
  app.get '/adm/experts*', loggedIn, admin, (req, r) -> file r, 'adm/experts'
  app.get '/adm/csvs*', loggedIn, admin, (req, r) -> file r, 'adm/csvs'
  app.get '/adm/inbound*', loggedIn, admin, (req, r) ->
    rSvc.getActive (d) =>
      r.render 'adm/inbound.html', { session: getSession(req), requests: JSON.stringify(d) }

  # api
  require('./lib/api/users')(app)
  require('./lib/api/companys')(app)
  require('./lib/api/tags')(app)
  require('./lib/api/experts')(app)
  require('./lib/api/requests')(app)
  require('./lib/api/mail')(app)


  # todo, brush up page
  app.get '/pair-programmers*', (req, r)-> file r, 'pairing'

  # todo, get agreements
  # app.get '/TOS', (req, r)-> file r, 'legal'
  # app.get '/privacy', (req, r)-> file r, 'legal'
  # app.get '/support', (req, r)-> file r, 'login'

  # todo, brush up page
  app.get '/edu/tags', (req, r) -> file r, 'edu/tags'

  # dev stuff
  app.get '/error-test', (req, r)-> throw new Error('my silly error')
  app.get '/adm/mail', loggedIn, admin, (req, r) -> file r, 'adm/mail'