exports = {}
BB = require './../../lib/BB'
M = require './Models'

#############################################################################
##  To render requests
#############################################################################


class exports.RequestRowView extends BB.BadassView
  tagName: 'tr'
  className: 'request'
  tmpl: require './templates/RequestRow'
  initialize: -> @model.on 'change', @render, @
  render: ->
    @$el.html @tmpl @templateData()
    @
  templateData: ->
    _.extend @model.toJSON(),
      contactName:  @model.get('company').contacts[0].fullName
      created:      @model.createdDateString()

class exports.RequestsView extends Backbone.View
  el: '#requestslist'
  tmpl: require './templates/Requests'
  initialize: (args) ->
    @collection.on 'reset add remove filter', @render, @
  render: ->
    @$el.html @tmpl { hasRequests: @collection.length > 0 }
    $list = @$('tbody').html ''
    for m in @collection.models
      $list.append new exports.RequestRowView( model: m ).render().el
    @


module.exports = exports