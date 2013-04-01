exports = {}


exports.set_htmlfixture = (html) ->
  $('body').append('<div id="fixture">'+html+'</div>')


exports.clear_htmlfixture = ->
  $('#fixture').remove()



exports.clean_setup = (ctx) ->

  # add objects to hold spys + stubs that we can gracefully clean up in tear_down
  ctx.spys = {}
  ctx.stubs = {}


exports.clean_tear_down = (ctx) ->

  # restore all our spys & stubs
  for own attr, value of ctx.spys
    ctx.spys[attr].restore

  for own attr, value of ctx.stubs
    ctx.stubs[attr].restore

  exports.clear_htmlfixture()


# used for an object that doesn't yet have a function defined for what we want to stub
exports.createStub = (ctx, obj, fnName, fn) ->
  obj[fnName] = ->
  ctx.stubs[fnName] = sinon.stub obj, fnName, fn


module.exports = exports
