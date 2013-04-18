models = require './Models'
collections = require './Collections'
views = require './Views'
routers = require './Routers'


module.exports.Page = class Page
  constructor: (pageData) ->
    @tags = new collections.Tags()
    #@tagsView = new views.SkillsView collection: @tags
    @selectedTags = new models.TagListModel()

    @tagsInputView = new views.TagsInputView collection: @tags, model: @selectedTags

    if pageData.tags? then @tags.reset pageData.tags else @tags.fetch({reset:true})


module.exports.Router = routers.TagsRouter

# LoadSPA allows us to initialize the app multiple times in integration tests
# without needing to re-require this app.coffee file or wait for jQuery.ready()
module.exports.LoadSPA = ->

  # Delegate instansiation of the router to the page, so we can inject
  # stuff by the server-side code rending data / options on the page
  window.initSPA(module.exports)


# On jquery ready load the Settings SPA (Single Page App)
$ ->
  module.exports.LoadSPA()