exports          = {}
BB               = require 'BB'
calcExpertCredit = require 'lib/mix/calcExpertCredit'

#############################################################################
##  To render all orders for the customers
#############################################################################

Handlebars.registerHelper "callDateTime", (utcDateString) ->
  day = moment utcDateString
  day.format("DD MMM <b>HH:mm</b>")

class exports.OrderRowView extends BB.BadassView
  tagName: 'tr'
  className: 'order'
  tmpl: require './templates/OrderRow'
  initialize: -> @listenTo @model, 'change', @render
  render: ->
    d = @model.extendJSON createdDate: @model.createdDateString()
    for li in d.lineItems
      _.extend li, calcExpertCredit([d], li.suggestion.expert._id)

    @$el.html @tmpl d
    @


class exports.OrdersView extends BB.BadassView
  el: '#orders'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    $list = @$('tbody').html ''
    for m in @collection.filteredModels
      $list.append new exports.OrderRowView( model: m ).render().el
    @


#############################################################################
##  To render all calls for the customer
#############################################################################


class exports.CallsView extends BB.BadassView
  el: '#calls'
  tmpl: require './templates/Call'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    for m in @collection.calls()
      m.isAdmin = @isAdmin
      @$el.append @tmpl m
    @


module.exports = exports
