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
    @$el.html @tmpl @tmplData()
    @
  isIncomplete: (expertCredit) ->
    expertCredit.total == 0 || expertCredit.completed < expertCredit.total
  tmplData: ->
    d = @model.toJSON()
    if d.payment.error? then d.error = d.payment.error[0]

    # now each lineitem knows whether it is paidout, simplifying templating
    opts = @model.get('payoutOptions') || {}
    pendingId = opts.lineItemId
    d.lineItems = d.lineItems.map (li) =>
      li.linePaidout = @model.isLineItemPaidOut li
      # hide the link so you can't double-click / double-payout:
      li.linePayoutPending = pendingId == li._id
      expertCredit = calcExpertCredit([d], li.suggestion.expert._id)
      li.incomplete = @isIncomplete expertCredit
      _.extend li, expertCredit

    _.extend d, {
      incomplete:         @isIncomplete d.lineItems[0] # paypal has one lineItem
      isPending:          d.paymentStatus is 'pending'
      isReceived:         d.paymentStatus is 'received'
      isPaidout:          d.paymentStatus is 'paidout'
      isPaypal:           d.paymentType is 'paypal'
      isStripe:           d.paymentType is 'stripe'
      contactName:        d.company.contacts[0].fullName
      contactPic:         d.company.contacts[0].pic
      contactEmail:       d.company.contacts[0].email
      createdDate:        @model.createdDateString()
    }



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
  logging: on
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
