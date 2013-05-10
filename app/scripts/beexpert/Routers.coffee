exports = {}


class exports.Router extends Backbone.Router

  routes:
    'welcome'       : 'welcome'
    'connect'       : 'connect'
    'info'          : 'info'
    'thanks'        : 'thanks'

  initialize: (args) ->
    @page = args.page
    @userAuthenticatedRoute()

  userAuthenticatedRoute: ->
    if @page.session.isGoogleAuthenticated() then @connect() else @welcome()

  welcome: ->
    # $log 'Router.welcome'
    @page.welcomeView.render()
    @hideShow '#welcome'

  connect: ->
    $log 'Router.connect'
    if !@isAuthenticated() then return @navigate 'welcome', { trigger: true }

    @page.expert.fetch success: (model, opts, resp) =>
      @page.connectView.render()
      @hideShow '#connect'

  info: ->
    $log 'Router.info', @page.expert.attributes
    if !@isAuthenticated() then return @navigate 'welcome', { trigger: true }

    # If we haven't go the user yet
    if @page.expert.get('_id') is 'me'
      return @navigate '#connect', { trigger:false }

    if @page.tags.length is 0 then @page.tags.fetch()

    @hideShow '#info'

  thanks: ->
    $log 'Router.thanks'
    @hideShow '#thanks'

  isAuthenticated: ->
    @page.session.isGoogleAuthenticated()

  hideShow: (selector) ->
    $('.main').hide()
    $(selector).show()


module.exports = exports