authz             = require './lib/identity/authz'
authd             = authz.LoggedIn()
adm               = authz.Admin()
{ file, render } = require './lib/util/viewRender'

module.exports = (app) ->

  # login / auth routes
  require('./lib/auth/base')(app)

  # home based on if authenticated
  renderHome = (req, r, next) ->
    if req.isAuthenticated() then next()
    else r.sendfile "./public/home.html"

  app.get '/', renderHome, render 'dashboard'

  # pages
  app.get '/login', file 'login'
  app.get '/be-an-expert*', file 'beexpert'
  app.get '/find-an-expert*', render 'request'
  app.get '/dashboard*', authd, render 'dashboard'
  app.get '/settings*', authd, render 'settings'
  app.get '/@:id', render 'book', ['params.id']
  app.get '/review/:id', render 'review', ['params.id']
  app.get '/review/book/:id', authd, render 'review', ['params.id']

  # TODO remove
  app.get '/adm/so', (req, res, next) =>
    console.log 'hi'
    res.sendfile './public/adm/so.html'

  # admin pages
  app.get '/adm/tags*', authd, adm, render 'adm/tags'
  app.get '/adm/marketingtags', authd, adm, render 'adm/marketingtags'
  app.get '/adm/csvs*', authd, adm, render 'adm/csvs'
  app.get '/adm/orders*', authd, adm, render 'adm/orders'
  app.get '/adm/companys*', authd, adm, render 'adm/companys'
  app.get '/adm/experts*', authd, adm, render 'adm/experts'
  app.get '/adm/inbound*', authd, adm, render 'adm/inbound'
  app.get '/adm/call/schedule/:id*', authd, adm, render 'adm/callSchedule', ['params.id']
  app.get '/adm/call/edit/:id*', authd, adm, render 'adm/callEdit', ['params.id']

  # api
  require('./lib/api/users')(app)
  require('./lib/api/companys')(app)
  require('./lib/api/tags')(app)
  require('./lib/api/experts')(app)
  require('./lib/api/requests')(app)
  require('./lib/api/requestCalls')(app)
  require('./lib/api/mail')(app)
  require('./lib/api/orders')(app)
  require('./lib/api/settings')(app)
  require('./lib/api/paymethods')(app)
  require('./lib/api/marketingtags')(app)
  require('./lib/api/videos')(app)

  app.get '/paypal/success/:id', authd, render 'payment/paypalSuccess', ['params.id']
  app.get '/paypal/cancel/:id', authd, render 'payment/paypalCancel', ['params.id']

  # todo, get agreements
  # app.get '/TOS', (req, r)-> file r, 'legal'
  # app.get '/privacy', (req, r)-> file r, 'legal'
  # app.get '/support', (req, r)-> file r, 'login'

  # dev stuff
  # app.get '/error-test', (req, r)-> throw new Error('my silly error')
