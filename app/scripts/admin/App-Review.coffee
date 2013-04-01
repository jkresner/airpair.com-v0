try require './../../stubs/base'
BB = require './../../lib/BB'
models = require './Models'
collections = require './Collections'
views = require './ViewsReview'
routers = require './Routers'


#instances of objects to make page work with router
module.exports.Page = class Page
  constructor: (pageData) ->

    @request = new models.Request()
    @company = new models.Company()

    @reviewView = new views.ReviewView model: @request, company: @company


module.exports.Router = routers.ReviewRouter

# LoadSPA allows us to initialize the app multiple times in integration tests
# without needing to re-require this app.coffee file or wait for jQuery.ready()
module.exports.LoadSPA = ->

  # Delegate instansiation of the router to the page, so we can inject
  # stuff by the server-side code rending data / options on the page
  window.initSPA(module.exports)


# On jquery ready load the Settings SPA (Single Page App)
$ ->
  module.exports.LoadSPA()