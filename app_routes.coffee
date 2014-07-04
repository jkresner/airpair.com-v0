authz            = require './lib/identity/authz'
authd            = authz.LoggedIn()
adm              = authz.Admin()
mm               = authz.Matchmaker()
{ file, render } = require './lib/util/viewRender'

module.exports = (app) ->

  # login / auth routes
  require('./lib/auth/base')(app)

  require('./app_landing')(app, render)

  renderHome = (req, r, n) ->
    if req.isAuthenticated() then n()
    else render('home')(req, r, n)

  app.get '/', renderHome, render 'dashboard'
  app.get '/book/me', authd, render 'bookme'

  # pages
  app.get '/login', file 'login'
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
  app.get '/adm/tags*', authd, adm, render 'adm/tags'
  app.get '/adm/marketingtags', authd, adm, render 'adm/marketingtags'
  app.get '/adm/orders*', authd, adm, render 'adm/orders'
  app.get '/adm/ang/orders*', authd, adm, render 'adm/ordersang'
  app.get '/adm/companys*', authd, adm, render 'adm/companys'
  app.get '/adm/experts*', authd, adm, render 'adm/experts'
  app.get '/adm/pipeline*', authd, adm, render 'adm/pipeline'

  app.get '/schedule/:id/*', authd, mm, render 'schedule', ['params.id']
  app.get '/schedule/:id', authd, mm, render 'schedule', ['params.id']

  # api
  require('./lib/api/users')(app)
  require('./lib/api/companys')(app)
  require('./lib/api/tags')(app)
  require('./lib/api/experts')(app)
  require('./lib/api/requests')(app)
  require('./lib/api/requestCalls')(app)
  require('./lib/api/orders')(app)
  require('./lib/api/settings')(app)
  require('./lib/api/paymethods')(app)
  require('./lib/api/marketingtags')(app)
  require('./lib/api/videos')(app)
  require('./lib/api/chat')(app)

  app.get '/paypal/success/:id', authd, render 'payment/paypalSuccess', ['params.id']
  app.get '/paypal/cancel/:id', authd, render 'payment/paypalCancel', ['params.id']

  # dev stuff
  # app.get '/error-test', (req, r)-> throw new Error('my silly error')
