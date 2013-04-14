exports = {}


class exports.Router extends Backbone.Router

  routes:
    '':             'userAuthenticatedRoute'
    'company':      'company'
    'request':      'request'

  initialize: (args) ->
    @page = args.page
    @listenTo @page.user, 'change', @userAuthenticatedRoute

  userAuthenticatedRoute: ->
    if @page.user.isAuthenticated() then @company() else @welcome()

  welcome: (args) ->
    $log 'Router.index'
    @hideShow '#welcome'

  company: ->
    $log 'Router.company'
    @hideShow '#company'

  request: (args) ->
    $log 'Router.request'
    @hideShow '#request'

  hideShow: (selector) ->
    $('.main').hide()
    $(selector).show()


module.exports = exports