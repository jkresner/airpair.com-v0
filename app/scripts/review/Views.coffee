exports = {}
BB = require './../../lib/BB'
M = require './Models'
SV = require './../shared/Views'

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
    if @model.get('company')?
      @$el.html @tmpl @model.toJSON()
    @



module.exports = exports