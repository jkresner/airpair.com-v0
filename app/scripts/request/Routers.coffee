exports = {}


class exports.Router extends Backbone.Router

  routes:
    'company':      'company'
    'request':      'request'

  initialize: (args) ->
    @page = args.page
    @page.user.fetch success: @userAuthenticatedRoute

      # if @user.isGoogleAuthenticated()
      #   if pageData.tags? then @tags.reset pageData.tags else @tags.fetch({reset:true})

  userAuthenticatedRoute: =>
    if @page.user.isGoogleAuthenticated() then @company() else @welcome()

  welcome: ->
    $log 'Router.index'
    @hideShow '#welcome'

  company: ->
    $log 'Router.company'
    if @page.tags.length is 0 then @page.tags.fetch()

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