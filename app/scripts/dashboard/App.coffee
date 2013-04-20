models = require './Models'
collections = require './Collections'
views = require './Views'
routers = require './Routers'
SessionPage = require('./../shared/App').SessionPage


module.exports.Page = class Page extends SessionPage

  initialize: (pageData) ->
    @requests = new collections.Requests()

    @requestsView = new views.RequestsView collection: @requests, model: @user

    @resetOrFectch @requests


module.exports.Router = routers.DashboardRouter

# LoadSPA allows us to initialize the app multiple times in integration tests
# without needing to re-require this app.coffee file or wait for jQuery.ready()
module.exports.LoadSPA = ->

  # Delegate instansiation of the router to the page, so we can inject
  # stuff by the server-side code rending data / options on the page
  window.initSPA(module.exports)


# On jquery ready load the Settings SPA (Single Page App)
$ ->
  module.exports.LoadSPA()