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
##  To render all experts for admin
#############################################################################

class exports.OrderRowView extends BB.ModelSaveView
  tagName: 'tr'
  className: 'order'
  tmpl: require './templates/OrderRow'
  events:
    'click .deleteOrder': 'deleteOrder'
    'click .payOutPayPalAdaptive': 'payOutPayPalAdaptive'
    'click .payOutPaypalSingle':   'payOutPaypalSingleExpert'
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
  deleteOrder: ->
    @model.destroy()
    @$el.remove()
  payOutPayPalAdaptive: (e) ->
    @model.set 'payoutOptions', { type: 'paypalAdaptive' }
    @save (e)
  renderError: (model, xhr, opts) => # BB doesnt recognize these server errors
    try res = JSON.parse(xhr.responseText)
    catch e then return console.log e.stack
    @model.set('payment', res.data)
  payOutPaypalSingleExpert: (e) =>
    lineItemId = $(e.target).data('id')
    @model.set 'payoutOptions', { type: 'paypalSingle', lineItemId: lineItemId }
    @save (e)
  getViewData: ->
    payOut: true


class exports.OrdersView extends BB.BadassView
  logging: on
  el: '#orders'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    $list = @$('tbody').html ''
    for m in @collection.filteredModels #.reverse()
      $list.append new exports.OrderRowView( model: m ).render().el
    @


module.exports = exports
