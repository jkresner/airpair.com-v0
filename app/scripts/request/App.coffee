BB = require './../../lib/BB'
models = require './Models'
collections = require './Collections'
views = require './Views'
routers = require './Routers'


#instances of objects to make page work with router
module.exports.Page = class Page
  constructor: (pageData) ->
    @user = new models.User()
    @company = new models.Company _id: 'me'
    @tags = new collections.Tags()
    @request = new models.Request()

    @companyFormView = new views.CompanyFormView model: @company
    @requestFormView = new views.RequestFormView model: @request, tags: @tags

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