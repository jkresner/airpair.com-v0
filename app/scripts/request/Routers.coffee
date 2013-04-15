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
    @page.company.fetch success: (m, opts, resp) =>
      m.populateFromGoogle @page.user
      @hideShow '#company'
      @request()

  request: ->
    $log 'Router.request'
    @hideShow '#request'
    @page.request.set 'companyId', @page.company.get('_id')

  hideShow: (selector) ->
    $('.main').hide()
    $(selector).show()


module.exports = exports