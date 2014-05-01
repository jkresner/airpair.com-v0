exports          = {}
BB               = require '../../lib/BB'
M                = require './Models'
Shared           = require '../shared/Views'
SM               = require '../shared/Models'
SC               = require '../shared/Collections'
sum              = require '../shared/mix/sum'
calcExpertCredit = require '../shared/mix/calcExpertCredit'

{calcTotal, calcRedeemed, calcCompleted} = calcExpertCredit

#############################################################################
##  To render all orders for the customers
#############################################################################

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
    for m in @collection.filteredModels #.reverse()
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
