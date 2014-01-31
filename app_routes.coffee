authz = require './lib/identity/authz'
loggedIn = authz.LoggedIn()
admin = authz.Admin()
ViewDataService = require('./lib/services/_viewdata')
viewData = new ViewDataService()
gSurveyPrxy = require('./lib/util/googleSurveyProxy')


file = (r, file) -> r.sendfile "./public/#{file}.html"

module.exports = (app) ->

  app.get '/api/survey-results/q1-tools', (req, r)->
    gSurveyPrxy 'https://docs.google.com/forms/d/1FLzM0-gJ1_BRJUmhhV9MLKZJLYiQ36Ydmb4iudCxjBE/viewanalytics', (cres) -> r.send cres

  # login / auth routes
  require('./lib/auth/base')(app)

  # pages
  app.get '/login', (req, r)-> file r, 'login'
  app.get '/be-an-expert*', (req, r)-> file r, 'beexpert'
  app.get '/find-an-expert*', (req, r)-> r.render 'request.html'

  app.get '/', (req, r) ->
    if !req.isAuthenticated()
      file r, 'homepage'
    else
      file r, 'dashboard'

  app.get '/dashboard*', loggedIn, (req, r) -> file r, 'dashboard'

  renderReview = (req, r, next) ->
    viewData.review req.params.id, req.user, (e, d) =>
      if e then return next e
      r.render 'review.html', _.extend d, { reqUrl: req.url, authenticated: req.isAuthenticated() }
  app.get '/review/:id', renderReview
  app.get '/review/book/:id', renderReview


  app.get '/settings*', loggedIn, (req, r) ->  r.render 'settings.html',
    { stripePK: cfg.payment.stripe.publishedKey }

  renderBook = (req, r, next) ->
    viewData.book req.params.id, req.user, (e, d) =>
      if e then return next e
      r.render 'book.html', d
  app.get '/@:id', renderBook

  # admin pages
  app.get '/adm/tags*', loggedIn, admin, (req, r) -> file r, 'adm/tags'
  app.get '/adm/marketingtags', loggedIn, admin, (req, r) -> file r, 'adm/marketingtags'
  app.get '/adm/experts*', loggedIn, admin, (req, r) -> file r, 'adm/experts'
  app.get '/adm/csvs*', loggedIn, admin, (req, r) -> file r, 'adm/csvs'
  app.get '/adm/orders*', loggedIn, admin, (req, r) -> file r, 'adm/orders'
  app.get '/adm/companys*', loggedIn, admin, (req, r) -> r.render 'adm/companys.html',
    { stripePK: cfg.payment.stripe.publishedKey }
  app.get '/adm/inbound*', loggedIn, admin, (req, r, next) ->
    viewData.inbound req.user, (e, d) =>
      if e then return next e
      r.render 'adm/inbound.html', d

  app.get '/adm/call/schedule/:requestId*', loggedIn, admin, (req, r, next) ->
    viewData.callSchedule req.params.requestId, (e, d) =>
      if e then return next e
      r.render 'adm/callSchedule.html', d
  app.get '/adm/call/edit/:callId*', loggedIn, admin, (req, r, next) ->
    viewData.callEdit req.params.callId, (e, d) =>
      if e then return next e
      r.render 'adm/callEdit.html', d

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

  app.get '/paypal/success/:id', loggedIn, (req, r, next) ->
    viewData.paypalSuccess req.params.id, req.user, (e, d) =>
      if e then return next e
      r.render 'payment/paypalSuccess.html', d

  app.get '/paypal/cancel/:id', loggedIn, (req, r, next) ->
    viewData.paypalCancel req.params.id, req.user, (e, d) =>
      if e then return next e
      r.render 'payment/paypalCancel.html', d

  app.get '/payment/register-stripe', loggedIn, (req, r, next) ->
    viewData.stripeCheckout req.user, req.query, (e, d) =>
      if e then return next e
      r.render 'payment/stripeRegister.html', d

  app.get '/payment/checkout-stripe', loggedIn, (req, r, next) ->
    viewData.stripeCheckout req.user, req.query, (e, d) =>
      if e then return next e
      r.render 'payment/stripeCheckout.html', d

  app.post '/payment/stripe-charge', (req, r, next) ->
    viewData.stripeCharge null, req.user, req.body.token, (e, d) =>
      if e then return next e
      r.render 'payment/stripeSuccess.html', d

    $log 'req', req.user, req.body
    r.send 200


  # todo, get agreements
  # app.get '/TOS', (req, r)-> file r, 'legal'
  # app.get '/privacy', (req, r)-> file r, 'legal'
  # app.get '/support', (req, r)-> file r, 'login'

  # dev stuff
  # app.get '/error-test', (req, r)-> throw new Error('my silly error')
  # app.get '/adm/mail', loggedIn, admin, (req, r) -> file r, 'adm/mail'
