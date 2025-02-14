# authz = require '../lib/identity/authz'
# authd = authz.LoggedIn()
# adm = authz.Admin()
# fbAuth = require '../lib/identity/fbAuth'
# mm = authz.Matchmaker()
# { redirect, file, render, renderTemplate, renderHome } = require '../lib/util/viewRender'
{ render } = require '../lib/util/viewRender'

module.exports = (app) ->

  ### login / auth routes ###
  # require('../lib/auth/base')(app)

  ### APIs ###
  app.use '/api', require('./api')

  ### REDIRECTS ###
  # redirect app, '/airconf/spreadsheets-graph-databases', '/neo4j/workshops/spreadsheets-graph-databases' # link from neo4j website
  # redirect app, '/solr/workshops/discovering-your-inned-search-engine', '/solr/workshops/discovering-your-inner-search-engine'
  # redirect app, '/auth/google', '/v1/auth/login'
  # redirect app, '/login', '/v1/auth/login'
  # redirect app, '/settings', '/billing'

  # app.get '/author/*', (req,res) -> res.redirect(301, '/posts/all')

  ### main site ###
  # app.get '/book/me', authd, render 'bookme'
  app.get '/admin', render 'admin'

  # angular
  # app.get '/adm/matching', render 'admin'
  # app.get '/site', authd, render 'site'
  # app.get '/settings/notifications', authd, render 'site'
  # app.get '/coming', authd, render 'site'
  # app.get '/adm/templates/orders_daily', authd, render 'adm/templates/orders_daily'

  # catchall for templates not pre-rendered
  # app.get '/templates/:scope/:template', renderTemplate

  # pages
  # app.get '/be-an-expert*', authd, render 'beexpert'
  # app.get '/find-an-expert*', authd, render 'request'`
  # app.get '/dashboard*', authd, render 'dashboard'
  # app.get '/settings*', authd, render 'settings'
  # app.get '/history', authd, render 'history', ['params.id']
  # app.get '/history/:id', authd, render 'history', ['params.id']
  # app.get '/book/:id', render 'book', ['params.id','query.code']
  # app.get '/review/:id', render 'review', ['params.id']
  # app.get '/review/book/:id', authd, render 'review', ['params.id']

  # admin pages
  # app.get '/adm/airconf/:code', authd, adm, render 'adm/airconfconsole', ['params.code']
  # app.get '/adm/tags*', authd, adm, render 'adm/tags'
  app.get '/adm/marketingtags', render 'adm/marketingtags'
  app.get '/adm/orders*', render 'adm/orders'
  app.get '/adm/ang/orders*', render 'adm/ordersang'
  app.get '/adm/companys*', render 'adm/companys'
  # app.get '/adm/experts*', authd, adm, render 'adm/experts'
  # app.get '/adm/emailtemplates', authd, adm, render 'adm/emailtemplates'
  # app.get '/adm/pipeline*', authd, adm, render 'adm/pipeline'

  # app.get '/schedule/:id/*', authd, mm, render 'schedule', ['params.id']
  # app.get '/schedule/:id', authd, mm, render 'schedule', ['params.id']

  # app.get '/paypal/success/:id', authd, render 'payment/paypalSuccess', ['params.id']
  # app.get '/paypal/cancel/:id', authd, render 'payment/paypalCancel', ['params.id']

  ### LANDING ###
  # app.get '/so10/:id', render 'landing/so10', ['params.id']
  # app.get '/so11/:id', render 'landing/so11', ['params.id']
  # app.get '/so12/:id', render 'landing/so12', ['params.id']
  # app.get '/so13/:id', render 'landing/so13', ['params.id']
  # app.get '/so14/:id', render 'landing/so14', ['params.id']
  # app.get '/so15/:id', render 'landing/so15', ['params.id']
  # app.get '/so16/:id', render 'landing/so16', ['params.id']
  # app.get '/so17/:id', render 'landing/so17', ['params.id']
  # app.get '/so18', render 'landing/so18'
  # app.get '/so19/:id', render 'landing/so17', ['params.id']
  # app.get '/so20/:id', render 'landing/so17', ['params.id']
  # app.get '/railsconf2014', render 'landing/railsconf'
  # app.get '/welcome-back', render 'landing/welcome-back', ['params.id']

  ### AIRCONF ROUTES ###
  # app.get '/workshops/me', authd, render 'workshop', ['params.id']
  # app.get '/:tag/workshops', render 'landing/airconf_tag', ['params.tag']
  # app.get '/:tag/workshops/:id', fbAuth(), render 'workshop', ['params.id', {template: 'workshop/detail'}, {template: 'shared/chat_template'}]

  # app.get '/airconf2014', render 'landing/airconf'
  # app.get '/airconf', (req, r) -> r.redirect req.url.replace('/airconf','/airconf2014')
  # app.get '/airconf-registration', authd, render 'landing/airconfreg'
  # app.get '/airconf-registration/thanks', authd, render 'landing/airconfreg'
  # app.get '/airconf-subscribe', render 'landing/airconfsubscribe'
  # app.get '/airconf-so-subscribe', render 'landing/airconfsosubscribe'
  # app.get '/airconf-promo/:id', render 'landing/airconfpromo', ['params.id']
  # app.get '/airconf2014/keynote/:id', fbAuth(), render 'keynote', ['params.id', {template: 'workshop/panel'}, {template: 'shared/chat_template'}]

