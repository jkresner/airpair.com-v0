models = require './Models'
collections = require './Collections'
views = require './Views'
routers = require './Routers'
SessionPage = require('./../shared/App').SessionPage


#instances of objects to make page work with router
module.exports.Page = class Page extends SessionPage
  constructor: (pageData) ->

    @selected = new models.Request()
    @requests = new collections.Requests()
    @tags = new collections.Tags()
    @experts = new collections.Experts()

    @requestsView = new views.RequestsView collection: @requests, model: @selected

    rfv = el: '#requestForm', model: @selected, collection: @requests, tags: @tags, experts: @experts
    @requestFormView = new views.RequestFormView rfv

    #@experts.on 'sync', ->
    #  setTimeout "router.navigate('request/514d6386a521340200000066', { trigger: true })", 100

    @resetOrFectch @requests, pageData.requests
    @resetOrFectch @tags, pageData.tags
    @resetOrFectch @experts, pageData.experts


module.exports.Router = routers.InboundRouter


# LoadSPA allows us to initialize the app multiple times in integration tests
# without needing to re-require this app.coffee file or wait for jQuery.ready()
module.exports.LoadSPA = ->

  # Delegate instansiation of the router to the page, so we can inject
  # stuff by the server-side code rending data / options on the page
  window.initSPA(module.exports)


# On jquery ready load the Settings SPA (Single Page App)
$ ->
  module.exports.LoadSPA()