exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

#############################################################################
##
#############################################################################

class exports.ListView extends BB.BadassView
  el: '#list'
  # tmpl: require './templates/Welcome'
  # events: { 'click .track': 'track' }
  # initialize: ->
  #   @e = addjs.events.customerLogin
  #   @e2 = addjs.events.customerWelcome
  # render: ->
  #   if !@timer? then @timer = new addjs.Timer(@e.category).start()
  #   @$el.html @tmpl()
  #   trackWelcome = => addjs.trackEvent @e2.category, @e2.name, @e2.uri, 0
  #   setTimeout trackWelcome, 400


module.exports = exports
