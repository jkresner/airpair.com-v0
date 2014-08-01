exports = {}
BB      = require 'BB'

#############################################################################
##  To render requests
#############################################################################
class exports.RequestsView extends Backbone.View
  el: '#requestslist'
  tmpl: require './templates/Requests'

  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render

  render: ->
    @$el.html @tmpl { hasRequests: @collection.length > 0 }
    $list = @$('tbody').html ''
    for m in @collection.models
      $list.append new exports.RequestRowView( model: m, id: m.id ).render().el
    @

class exports.RequestRowView extends BB.BadassView
  tagName: 'tr'
  className: 'request'
  tmpl: require './templates/RequestRow'

  initialize: -> @model.on 'change', @render, @

  render: ->
    @$el.html @tmpl @templateData()
    @

  templateData: ->
    suggested = _.select @model.sortedSuggestions(), (suggestion) ->
      suggestion.expertStatus != 'waiting'
    _.extend @model.toJSON(),
      contactName: @model.get('company').contacts[0].fullName
      created: @model.createdDateString()
      suggested: suggested

module.exports = exports
