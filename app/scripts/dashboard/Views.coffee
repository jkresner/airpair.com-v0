exports = {}
BB      = require './../../lib/BB'
M       = require './Models'

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
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    @$el.html @tmpl { hasRequests: @collection.length > 0 }
    $list = @$('tbody').html ''
    for m in @collection.models
      $list.append new exports.RequestRowView( model: m, id: m.id ).render().el
    @

class exports.CallRowView extends BB.BadassView
  tagName: 'tr'
  className: 'call'
  tmpl: require './templates/CallRow'
  initialize: ->
  render: ->
    @$el.html @tmpl @call
    @

class exports.CallsView extends Backbone.View
  el: '#callslist'
  tmpl: require './templates/Calls'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    @$el.html @tmpl { hasCalls: @collection.length > 0 }
    $list = @$('tbody').html ''
    for m in @collection.models
      request = m.toJSON()
      experts = _.pluck(request.suggested, 'expert')
      for call in request.calls
        call.requestId = request._id
        call.expert = _.find experts, (e) -> e._id == call.expertId
        $list.append new exports.CallRowView( call: call, id: m.id ).render().el
    @


class exports.OrderRowView extends BB.BadassView
  tagName: 'tr'
  className: 'order'
  tmpl: require './templates/OrderRow'
  initialize: -> @model.on 'change', @render, @
  render: ->
    d = @model.toJSON()
    d.created = moment(d.utc).format 'MMM DD'
    @$el.html @tmpl d
    @

class exports.OrdersView extends Backbone.View
  el: '#orderslist'
  tmpl: require './templates/Orders'
  initialize: (args) ->
    @listenTo @collection, 'reset add remove filter', @render
  render: ->
    @$el.html @tmpl { hasOrders: @collection.length > 0 }
    $list = @$('tbody').html ''
    for m in @collection.models
      $list.append new exports.OrderRowView( model: m, id: m.id ).render().el
    @

module.exports = exports
