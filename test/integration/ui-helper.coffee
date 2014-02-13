exports = {}

## TODO figure out how to remove this reference
models = require '/scripts/shared/Models'

###############################################################################
## Private helper functions
###############################################################################


# inject html below our mocha test runner to execute a test with html context
setHtmlfixture = (html) ->
  $('body').append('<div id="fixture">'+html+'</div>')

clearHtmlfixture = ->
  $('.datepicker').stop()
  $('.timepicker').timepicker?('remove')
  $('#fixture').remove()


###############################################################################
## Exported helper functions
###############################################################################


""" showsError: short hand for checking a bootstrap validation error """
exports.showsError = (input) ->
  controls = input.parent()
  # $log 'controls', controls
  $(controls).find('.error-message').length > 0


""" setInitApp
allows us to redefine initApp() from one test to another
since normally in a badass-backbone app it would be defined on the html
page and we can't do that from a mocha test harness page """
exports.setInitApp = (ctx, routerPath, sessionUser) ->

  sessionUser = { authenticated: false } if !sessionUser?

  window.initApp = (pageData, callback) ->
    # $log 'initApp', routerPath, pageData

    pageData = {} if !pageData?

    Router = require routerPath

    # turn pushState off so browser doesn't navigate away from mocha test page
    Router::pushState = off

    # stop router loading google analytics & other external scripts
    Router::enableExternalProviders = off

    # stub out getting the users details via ajax
    Router::_setSession = (pageData, callback) ->
      session = pageData.session
      if !session? then session = sessionUser
      # $log '_setSession override', session
      @app = session: new models.User session

      @superConstructor.call @, pageData, callback

    # set our global router object as normal in badass-backbone convention
    window.router = new Router pageData, callback
    ctx.app = window.router.app


""" cleanSetup
called in conjunction with cleanTearDown:
1) loads our html fixture
2) sets up spys & stubs objects to be auto restored on test completion
"""
exports.cleanSetup = (ctx, fixtureHtml) ->

  if fixtureHtml? then setHtmlfixture fixtureHtml

  # add objects to hold spys + stubs that we can gracefully clean up in tear_down
  ctx.spys = {}
  ctx.stubs = {}

""" cleanTearDown
called in conjunction with cleanSetup:
1) clears our html fixture
2) auto restores spys and stubs
3) switches off the current router
"""
exports.cleanTearDown = (ctx) ->

  # restore all our spys & stubs
  for own attr, value of ctx.spys
    ctx.spys[attr].restore()

  for own attr, value of ctx.stubs
    ctx.stubs[attr].restore()

  clearHtmlfixture()

  # stop our router doing anything before "beforeEach" executes for next test
  if window.router?
    Backbone.history.stop()
    # so we can press refresh in the browser easily
    delete ctx.app
    delete window.router
    window.location = '#'
    # router.navigate '#'


# """ createStub used for an object that doesn't yet have
# a function defined for what we want to stub """
# exports.createStub = (ctx, obj, fnName, fn) ->
#   obj[fnName] = ->
#   ctx.stubs[fnName] = sinon.stub obj, fnName, fn


exports.setSession = (userKey, callback) ->
  $.ajax(url: "/set-session/#{userKey}").done( -> callback() )


module.exports = exports
