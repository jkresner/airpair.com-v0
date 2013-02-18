try require './../../stubs/base'
BB = require './../../lib/BB'
models = require './Models'
collections = require './Collections'
views = require './Views'
routers = require './Routers'


#instances of objects to make page work with router
module.exports.Page = class Page
  constructor: (pageData) ->
    @leads = new collections.Leads()

    @currentLead = new models.Lead()

    @inProgressLeadsView = new views.InProgressLeadsView collection: @leads
    @leadView = new views.LeadView model: @currentLead

    @leads.reset pageData.leads



module.exports.Router = routers.AdminRouter

# LoadSPA allows us to initialize the app multiple times in integration tests
# without needing to re-require this app.coffee file or wait for jQuery.ready()
module.exports.LoadSPA = ->

  # Delegate instansiation of the router to the page, so we can inject
  # stuff by the server-side code rending data / options on the page
  window.initSPA(module.exports)


# On jquery ready load the Settings SPA (Single Page App)
$ ->
  module.exports.LoadSPA()