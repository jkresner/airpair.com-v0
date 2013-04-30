exports = {}


class exports.Router extends Backbone.Router

  routes:
    'contactInfo'   : 'contactInfo'
    'request'       : 'request'
    'thanks'        : 'thanks'
    'update/:id'    : 'update'

  initialize: (args) ->
    @page = args.page
    @userAuthenticatedRoute()

  userAuthenticatedRoute: ->
    if @page.session.isGoogleAuthenticated() then @contactInfo() else @welcome()

  welcome: ->
    # $log 'Router.welcome'
    @hideShow '#welcome'

  contactInfo: ->
    # $log 'Router.contactInfo'
    @page.company.fetch success: (m, opts, resp) =>
      m.populateFromGoogle @page.session

    @hideShow '#contactInfo'
    # @request()
  request: ->
    # $log 'Router.request'
    if @page.tags.length is 0 then @page.tags.fetch()

    @hideShow '#request'
    @page.request.set
      company: @page.company.attributes

  thanks: ->
    # $log 'Router.thanks'
    @hideShow '#thanks'

  update: (id) ->
    @page.request.set '_id': id
    @page.request.fetch success: (model, opts, resp) =>
      @page.company.set '_id': model.get('company')._id
      @company()

  hideShow: (selector) ->
    $('.main').hide()
    $(selector).show()


module.exports = exports