{workshops}    = require './lib/services/_viewdata.data'
authz          = require './lib/identity/authz'
authd          = authz.LoggedIn()

module.exports = (app, render) ->

  app.get '/so10/:id', render 'landing/so10', ['params.id']
  app.get '/so11/:id', render 'landing/so11', ['params.id']
  app.get '/so12/:id', render 'landing/so12', ['params.id']
  app.get '/so13/:id', render 'landing/so13', ['params.id']
  app.get '/so14/:id', render 'landing/so14', ['params.id']
  app.get '/so15/:id', render 'landing/so15', ['params.id']
  app.get '/so16/:id', render 'landing/so16', ['params.id']
  app.get '/so17/:id', render 'landing/so17', ['params.id']
  app.get '/so18', render 'landing/so18'
  app.get '/so19/:id', render 'landing/so17', ['params.id']

  app.get '/bsa02', render 'landing/bsa02'

  checkSession = (req, r, n) ->
    workshop = _.find workshops, (s) -> s.slug == req.params.id
    if workshop then n()
    else
      r.status 404
      render('landing/airconf')(req, r, n)

  app.get '/airconf2014', render 'landing/airconf'
  app.get '/airconf2014/foyer', authd, render 'landing/airconf_foyer'
  app.get '/airconf', (req, r) -> r.redirect req.url.replace('/airconf','/airconf2014')
  app.get '/airconf-registration', authd, render 'landing/airconfreg'
  app.get '/airconf-subscribe', render 'landing/airconfsubscribe'
  app.get '/airconf-so-subscribe', render 'landing/airconfsubscribe'
  app.get '/airconf-promo/:id', render 'landing/airconfpromo', ['params.id']

  app.get '/airconf2014/keynote/:id', render 'landing/airconfkeynote', ['params.id']

  app.get '/railsconf2014', render 'landing/railsconf'
  app.get '/rails/consulting', render 'landing/railsconsulting'
  app.get '/googleio-specials', render 'landing/googleio'

  app.get '/welcome-back', render 'landing/welcome-back', ['params.id']
