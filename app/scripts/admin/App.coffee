try require './../../stubs/base'
BB = require './../../lib/BB'
models = require './Models'
collections = require './Collections'
views = require './Views'
routers = require './Routers'


#instances of objects to make page work with router
module.exports.Page = class Page
  constructor: (pageData) ->
    @skills = new collections.Skills()
    @devs = new collections.Devs()
    @companys = new collections.Companys()
    @requests = new collections.Requests()

    @currentRequest = new models.Request()

    @requestsView = new views.RequestsView collection: @requests
    @requestFormView = new views.RequestFormView model: @currentRequest, companys: @companys, devs: @devs, collection: @requests
    @skillsView = new views.SkillsView collection: @skills
    @devsView = new views.DevsView collection: @devs
    @companysView = new views.CompanysView collection: @companys

    if pageData.skills? then @skills.reset pageData.skills else @skills.fetch({reset:true})
    if pageData.devs? then @devs.reset pageData.devs else @devs.fetch({reset:true})
    if pageData.companys? then @companys.reset pageData.companys else @companys.fetch({reset:true})
    if pageData.requests? then @requests.reset pageData.requests else @requests.fetch({reset:true})


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