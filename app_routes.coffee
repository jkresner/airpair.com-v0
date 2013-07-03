authz = require './lib/identity/authz'
loggedIn = authz.LoggedIn()
admin = authz.Admin()
ViewDataService = require('./lib/services/_viewdata')
viewData = new ViewDataService()

file = (r, file) -> r.sendfile "./public/#{file}.html"

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

  renderReview = (req, r) ->
    viewData.review req.params.id, req.user, (d) => r.render 'review.html', d
  app.get '/review/:id', renderReview
  app.get '/review/book/:id', renderReview

  # admin pages
  app.get '/adm/tags*', loggedIn, admin, (req, r) -> file r, 'adm/tags'
  app.get '/adm/experts*', loggedIn, admin, (req, r) -> file r, 'adm/experts'
  app.get '/adm/csvs*', loggedIn, admin, (req, r) -> file r, 'adm/csvs'
  app.get '/adm/inbound*', loggedIn, admin, (req, r) ->
    viewData.inbound req.user, (d) => r.render 'adm/inbound.html', d

  # api
  require('./lib/api/users')(app)
  require('./lib/api/companys')(app)
  require('./lib/api/tags')(app)
  require('./lib/api/experts')(app)
  require('./lib/api/requests')(app)
  require('./lib/api/mail')(app)
  require('./lib/api/orders')(app)

  app.get '/paypal/success', (req, r) -> r.send 'paypal success'
  app.get '/paypal/cancel', (req, r) -> r.send 'paypal cancel'

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