exports = {}
BB = require './../../lib/BB'
M = require './Models'
Shared = require './../shared/Views'

#############################################################################
##  To render all experts for admin
#############################################################################

class exports.ExpertRowView extends Backbone.View
  className: 'expert'
  tmpl: require './templates/Row'
  initialize: -> @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @model.toJSON()
    @


class exports.ExpertsView extends Backbone.View
  el: '#experts'
  initialize: (args) ->
    @collection.on 'reset add remove filter', @render, @
  render: ->
    $list = @$el.html ''
    for m in @collection.models
      $list.append new exports.ExpertRowView( model: m ).render().el
    @


exports.ExpertView = Shared.ExpertView


module.exports = exports