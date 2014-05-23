exports          = {}
BB               = require 'BB'
M                = require './Models'
Shared           = require '../../shared/Views'
SM               = require '../../shared/Models'
SC               = require '../../shared/Collections'
sum              = require 'lib/mix/sum'
calcExpertCredit = require 'lib/mix/calcExpertCredit'

{calcTotal, calcRedeemed, calcCompleted} = calcExpertCredit

#############################################################################
##  To render all experts for admin
#############################################################################

# TODO on paypal payout, Uncaught TypeError: Cannot read property 'qtyRedeemed' of undefined

class exports.FiltersView extends BB.BadassView
  el: '#filters'
  events:
    'click .btn': 'filter'
  initialize: ->
    @marketingTagView = new Shared.MarketingTagsInputView
      collection: @marketingTags, model: @dummyRequest
    @listenTo @dummyRequest, 'change:marketingTags', @filter
  filter: (e) ->
    if e && e.target
      $btn = $(e.target)
      @$('button').removeClass('btn-warning')
      $btn.addClass('btn-warning')

      @timeString = $btn.text().toLowerCase()
      @month = $btn.data('month')

    @marketingTags = @dummyRequest.get('marketingTags')
    @collection.filterFilteredModels { @timeString, @month, @marketingTags }


class exports.OrderRowView extends BB.ModelSaveView
  tagName: 'tr'
  className: 'order'
  tmpl: require './templates/Row'
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
  el: '#orders'
  tmpl: require './templates/RowsSummary'
  firstRender: true
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    # first render default to month only
    if @firstRender
      @firstRender = false
      return @collection.filterFilteredModels { timeString: 'Mth' }

    $list = @$('tbody').html ''
    totalRevenue = 0
    totalProfit = 0
    totalHours = 0
    totalRedeemed = 0
    totalCompleted = 0
    orderCount = @collection.filteredModels.length
    expertIds = []
    for m in @collection.filteredModels #.reverse()
      $list.append new exports.OrderRowView( model: m ).render().el
      totalProfit += m.get 'profit'
      totalRevenue += m.get 'total'
      for li in m.get 'lineItems'
        expertIds.push li.suggestion.expert._id
        if 'pending' == m.get 'paymentStatus' then continue
        totalHours += calcTotal [li]
        totalRedeemed += calcRedeemed [li]
        totalCompleted += calcCompleted [li]
    filteredModelsJson = _.pluck @collection.filteredModels, 'attributes'
    requestCount = _.uniq(_.pluck filteredModelsJson, 'requestId').length
    customerCount = _.uniq(_.pluck filteredModelsJson, 'userId').length
    expertCount = _.uniq(expertIds).length
    @$('#rowsSummary').html @tmpl { totalProfit, totalRevenue, customerCount,
      requestCount, orderCount, totalHours, totalRedeemed, totalCompleted,
      expertCount }
    @


class exports.OrderView extends BB.ModelSaveView
  el: '#order'
  tmpl: require './templates/Edit'
  events:
    'click .swap': 'swapExpert'
  initialize: (args) ->
    @listenTo @request, 'change', @render
  render: =>
    {lineItems,payment} = @model.attributes
    order = _.omit @model.attributes, ['lineItems','payment']

    cantSwap = false
    if @model.get('paymentStatus') is 'paidout'
      cantSwap = 'Cant swap already paidout order'
    else if lineItems.length != 1
      cantSwap = 'Swap only supported with 1 expert on order'
    else if order.paymentType != 'stripe'
      cantSwap = 'Swap only support for stripe orders. Edit payment type by hand?'
    else
      li = lineItems[0]
      canSwapExpert = true
      toSwap = []
      for s in @request.get('suggested')
        if s.expertStatus is 'available' && s._id != li.suggestion._id
          toSwap.push s

    @$el.html @tmpl
      lineItems: JSON.stringify(lineItems, null, 1)
      payment: JSON.stringify(payment, null, 1)
      order: JSON.stringify(order, null, 1)
      request: @request.toJSON()
      calls: @request.calls()
      canSwapExpert: canSwapExpert
      toSwap: toSwap
      cantSwap: cantSwap
    @
  swapExpert: (e) ->
    suggestion = @request.suggestion $(e.target).data('expertid')
    @model.save { swapExpert: { suggestion } }, { success: => @request.fetch() }
    false



module.exports = exports
