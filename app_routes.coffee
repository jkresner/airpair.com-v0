authz = require './lib/identity/authz'
authd = authz.LoggedIn()
adm = authz.Admin()
fbAuth = require './lib/identity/fbAuth'
mm = authz.Matchmaker()
{ file, render, renderTemplate } = require './lib/util/viewRender'

module.exports = (app) ->

  # login / auth routes
  require('./lib/auth/base')(app)

  require('./app_landing')(app, render)
  require('./app_redirects')(app, render)

  renderHome = (req, r, n) ->
    if req.isAuthenticated() then n()
    else render('home')(req, r, n)

  app.get '/', renderHome, render 'dashboard'
  app.get '/book/me', authd, render 'bookme'

  # angular site pages
  require('./lib/api/workshops')(app) # keep above :tag/workshops

  app.get '/admin', authd, adm, render 'admin'
  app.get '/adm/matching', authd, adm, render 'admin'
  app.get '/site', authd, render 'site'
  app.get '/settings/notifications', authd, render 'site'
  app.get '/coming', authd, render 'site'

  # angular templates
  app.get '/adm/templates/orders_daily', authd, render 'adm/templates/orders_daily'

  # catchall for templates not pre-rendered
  app.get '/templates/:scope/:template', renderTemplate

  # pages
  app.get '/login', render 'login'
  app.get '/be-an-expert*', render 'beexpert'
  app.get '/find-an-expert*', render 'request'
  app.get '/dashboard*', authd, render 'dashboard'
  app.get '/settings*', authd, render 'settings'
  app.get '/history', authd, render 'history', ['params.id']
  app.get '/history/:id', authd, render 'history', ['params.id']
  app.get '/book/:id', render 'book', ['params.id','query.code']
  app.get '/review/:id', render 'review', ['params.id']
  app.get '/review/book/:id', authd, render 'review', ['params.id']

  # admin pages
  app.get '/adm/airconf/:code', authd, adm, render 'adm/airconfconsole', ['params.code']
  app.get '/adm/tags*', authd, adm, render 'adm/tags'
  app.get '/adm/marketingtags', authd, adm, render 'adm/marketingtags'
  app.get '/adm/orders*', authd, adm, render 'adm/orders'
  app.get '/adm/ang/orders*', authd, adm, render 'adm/ordersang'
  app.get '/adm/companys*', authd, adm, render 'adm/companys'
  app.get '/adm/experts*', authd, adm, render 'adm/experts'
  app.get '/adm/emailtemplates', authd, adm, render 'adm/emailtemplates'
  app.get '/adm/pipeline*', authd, adm, render 'adm/pipeline'

  app.get '/schedule/:id/*', authd, mm, render 'schedule', ['params.id']
  app.get '/schedule/:id', authd, mm, render 'schedule', ['params.id']

  # api
  require('./lib/api/session')(app)
  require('./lib/api/feedback')(app)
  require('./lib/api/users')(app)
  require('./lib/api/companys')(app)
  require('./lib/api/tags')(app)
  require('./lib/api/matchers')(app)
  require('./lib/api/experts')(app)
  require('./lib/api/requests')(app)
  require('./lib/api/requestCalls')(app)
  require('./lib/api/orders')(app)
  require('./lib/api/settings')(app)
  require('./lib/api/paymethods')(app)
  require('./lib/api/marketingtags')(app)
  require('./lib/api/videos')(app)
  require('./lib/api/chat')(app)
  require('./lib/api/landingPage')(app)
  require('./lib/api/emailTemplates')(app)

  app.get '/paypal/success/:id', authd, render 'payment/paypalSuccess', ['params.id']
  app.get '/paypal/cancel/:id', authd, render 'payment/paypalCancel', ['params.id']

  # dev stuff
  # app.get '/error-test', (req, r)-> throw new Error('my silly error')
