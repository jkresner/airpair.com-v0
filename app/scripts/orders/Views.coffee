exports = {}
BB = require '../../lib/BB'
M = require './Models'
Shared = require '../shared/Views'
SM = require '../shared/Models'
SC = require '../shared/Collections'
MarketingTagsInputView = Shared.MarketingTagsInputView

#############################################################################
##  To render all experts for admin
#############################################################################

class exports.FiltersView extends BB.BadassView
  el: '#filters'
  events:
    'click .btn': 'timeFilter'
  initialize: ->
    marketingTags = new SC.MarketingTags()
    marketingTags.fetch()
    @fakeRequest = new SM.Request(marketingTags: [])
    @marketingTagView = new MarketingTagsInputView(collection: marketingTags, model: @fakeRequest)
    @listenTo @fakeRequest, 'change:marketingTags', @tagFilter

  timeFilter: (e) ->
    $btn = $(e.currentTarget)
    @$('button').removeClass('btn-warning')
    $btn.addClass('btn-warning')

    @timeString = $btn.text().toLowerCase()
    @month = $btn.data('month')
    @filter(@timeString, @month, @marketingTags)

  tagFilter: ->
    @marketingTags = @fakeRequest.get('marketingTags')
    @filter(@timeString, @month, @marketingTags)

  filter: (timeString, month, marketingTags) ->
    @collection.filterFilteredModels
      timeString: timeString
      month: month
      marketingTags: marketingTags


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
      li

    _.extend d, {
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

class exports.OrdersView extends Backbone.View
  # logging: on
  el: '#orders'
  tmpl: require './templates/RowsSummary'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    $list = @$('tbody').html ''
    totalRevenue = 0
    totalProfit = 0
    hourCount = 0
    orderCount = @collection.filteredModels.length
    expertIds = []
    for m in @collection.filteredModels #.reverse()
      $list.append new exports.OrderRowView( model: m ).render().el
      totalProfit += m.get 'profit'
      totalRevenue += m.get 'total'
      for li in m.get 'lineItems'
        hourCount += li.qty
        expertIds.push li.suggestion.expert._id
    filteredModelsJson = _.pluck @collection.filteredModels, 'attributes'
    requestCount = _.uniq(_.pluck filteredModelsJson, 'requestId').length
    customerCount = _.uniq(_.pluck filteredModelsJson, 'userId').length
    expertCount = _.uniq(expertIds).length
    @$('#rowsSummary').html @tmpl {totalProfit,totalRevenue,customerCount,requestCount,hourCount,orderCount,expertCount}
    @


class exports.OrderView extends BB.ModelSaveView
  # logging: on
  el: '#order'
  initialize: (args) ->
    @listenTo @model, 'change', @render
  render: ->
    @$('pre').text JSON.stringify(@model.toJSON(), null, 2)
    @

module.exports = exports
