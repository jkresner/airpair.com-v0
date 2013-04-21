exports = {}


class exports.Router extends Backbone.Router

  routes:
    'connect'       : 'connect'
    'info'          : 'info'
    'thanks'        : 'thanks'

  initialize: (args) ->
    @page = args.page
    @userAuthenticatedRoute()

  userAuthenticatedRoute: ->
    if @page.session.isGoogleAuthenticated() then @connect() else @welcome()

  welcome: ->
    $log 'Router.welcome'
    @hideShow '#welcome'

  connect: ->
    $log 'Router.connect'
    @page.expert.fetch success: (m, opts, resp) =>
      m.populateFromUser @page.session
      @hideShow '#connect'

  info: ->
    if @page.tags.length is 0 then @page.tags.fetch()
    $log 'Router.info'
    @hideShow '#info'

  thanks: ->
    $log 'Router.thanks'
    @hideShow '#thanks'

  hideShow: (selector) ->
    $('.main').hide()
    $(selector).show()


module.exports = exports