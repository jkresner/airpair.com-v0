BB = require './../../lib/BB'
models = require './Models'
collections = require './Collections'
views = require './Views'
routers = require './Routers'
SessionPage = require('./../shared/App').SessionPage


#instances of objects to make page work with router
module.exports.Page = class Page extends SessionPage

  initialize: (pageData) ->
    @expert = new models.Expert _id: 'me'
    @tags = new collections.Tags()

    @connectFormView = new views.ConnectFormView model: @expert, session: @session
    @infoFormView = new views.InfoFormView model: @expert, tags: @tags
    @expertStep1View = new views.ExpertView el: '#expertStep1', model: @expert
    @expertStep2View = new views.ExpertView el: '#expertStep2', model: @expert



module.exports.Router = routers.Router

# LoadSPA allows us to initialize the app multiple times in integration tests
# without needing to re-require this app.coffee file or wait for jQuery.ready()
module.exports.LoadSPA = ->

  # Delegate instansiation of the router to the page, so we can inject
  # stuff by the server-side code rending data / options on the page
  window.initSPA(module.exports)


# On jquery ready load the Settings SPA (Single Page App)
$ ->
  module.exports.LoadSPA()