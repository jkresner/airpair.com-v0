exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################
##  To render requests
#############################################################################


class exports.RequestRowView extends Backbone.View
  className: 'request'
  tmpl: require './templates/RequestRow'
  initialize: -> @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @model.toJSON()
    @


class exports.RequestsView extends Backbone.View
  el: '#requests'
  initialize: (args) ->
    @collection.on 'reset add remove filter', @render, @
  render: ->
    $list = @$el.html ''
    for m in @collection.models
      $list.append new exports.RequestRowView( model: m ).render().el
    @


module.exports = exports