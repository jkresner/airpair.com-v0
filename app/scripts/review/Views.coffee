exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################
##  To render requests
#############################################################################

class exports.RequestInfoView extends BB.BadassView
  logging: on
  el: '#requestInfo'
  tmpl: require './templates/Info'
  initialize: (args) ->
    @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @model.toJSON()
    @


module.exports = exports