exports = {}
BB = require './../../lib/BB'
M = require './Models'
Shared = require './../shared/Views'

#############################################################################
##  To render all experts for admin
#############################################################################

class exports.ExpertRowView extends Backbone.View
  tagName: 'tr'
  className: 'expert'
  tmpl: require './templates/Row'
  initialize: -> @model.on 'change', @render, @
  render: ->
    d = (_.extend @model.toJSON(), { hasLinks: @model.hasLinks() } )
    @$el.html @tmpl d
    @


class exports.ExpertsView extends Backbone.View
  el: '#experts'
  initialize: (args) ->
    @collection.on 'reset add remove filter', @render, @
  render: ->
    $list = @$('tbody').html ''
    for m in @collection.models
     $list.append new exports.ExpertRowView( model: m ).render().el
    @$('.count').html @collection.models.length
    @


exports.ExpertView = Shared.ExpertView


module.exports = exports