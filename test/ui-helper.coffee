models = require '/scripts/shared/Models'

data =
  users: require '/test/data/users'

exports = {}


exports.showsError = (input) ->
  controls = input.parent()
  # $log 'controls', controls
  $(controls).find('.error-message').length > 0


exports.set_htmlfixture = (html) ->
  $('body').append('<div id="fixture">'+html+'</div>')


exports.clear_htmlfixture = ->
  $('.datetimepicker').datetimepicker('remove')
  $('#fixture').remove()

exports.clean_setup = (ctx, fixtureHtml) ->

  if fixtureHtml? then exports.set_htmlfixture fixtureHtml

  # add objects to hold spys + stubs that we can gracefully clean up in tear_down
  ctx.spys = {}
  ctx.stubs = {}


exports.set_initSPA = (spaPath) ->

  window.initSPA = (SPA) =>
    # stub out getting the users details via ajax
    SPA.Page.__super__.constructor = (pageData, callback) ->
      # $log 'SPA const override', pageData.sessionObj, @
      sessionObj = pageData.sessionObj
      if !sessionObj? then sessionObj = data.users[0]
      @session = new models.User sessionObj
      @initialize pageData
      callback @

  SPA = require(spaPath)

exports.LoadSPA = (SPA, sessionObj) ->
  # create out app
  new SPA.Page { sessionObj: sessionObj }, (page) ->
    window.router = new SPA.Router page: page


exports.clean_tear_down = (ctx) ->

  # restore all our spys & stubs
  for own attr, value of ctx.spys
    ctx.spys[attr].restore()

  for own attr, value of ctx.stubs
    ctx.stubs[attr].restore()

  exports.clear_htmlfixture()


# used for an object that doesn't yet have a function defined for what we want to stub
exports.createStub = (ctx, obj, fnName, fn) ->
  obj[fnName] = ->
  ctx.stubs[fnName] = sinon.stub obj, fnName, fn


module.exports = exports
