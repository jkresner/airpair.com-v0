exports = {}
BB = require './../../lib/BB'
M = require './Models'
Shared = require './../shared/Views'

#############################################################################
##  To render all experts for admin
#############################################################################

class exports.OrderRowView extends BB.ModelSaveView
  tagName: 'tr'
  className: 'order'
  tmpl: require './templates/Row'
  events:
    'click .deleteOrder': 'deleteOrder'
    'click .payOut': 'payOutToExperts'
  initialize: -> @listenTo @model, 'change', @render
  render: ->
    @$el.html @tmpl @tmplData()
    @
  tmplData: ->
    d = @model.toJSON()
    if d.payment.error? then d.error = d.payment.error[0]
    _.extend d, {
      isPending:          d.paymentStatus is 'pending'
      isReceived:         d.paymentStatus is 'received'
      contactName:        d.company.contacts[0].fullName
      contactPic:         d.company.contacts[0].pic
      contactEmail:       d.company.contacts[0].email
      createdDate:        @model.createdDateString()
    }
  deleteOrder: ->
    @model.destroy()
    @$el.remove()
  payOutToExperts: (e) ->
    @save (e)
  getViewData: ->
    payOut: true

class exports.OrdersView extends Backbone.View
  # logging: on
  el: '#orders'
  tmpl: require './templates/RowsSummary'
  events: { 'click .selectOrder': 'select' }
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    $list = @$('tbody').html ''
    totalRevenue = 0
    totalProfit = 0
    orderCount = @collection.models.length
    for m in @collection.models
      $list.append new exports.OrderRowView( model: m ).render().el
      totalProfit += m.get 'profit'
      totalRevenue += m.get 'total'
    @$('#rowsSummary').html @tmpl {totalProfit,totalRevenue,orderCount}
    @
  select: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).data('id')
    expert = _.find @collection.models, (m) -> m.id.toString() == id
    @model.set expert.attributes
    alert("order #{id} selected")


class exports.OrderFormView extends BB.ModelSaveView
  # logging: on
  el: '#orderForm'
  initialize: (args) ->
  render: ->
    @


module.exports = exports