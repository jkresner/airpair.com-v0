exports = {}
BB = require './../../lib/BB'
Shared = require './../shared/Models'


exports.User = Shared.User


class exports.Order extends BB.BadassModel
  urlRoot: '/api/orders'
  defaults:
    total: 0
  lineItem: (index) ->
    # first try lookup by suggestion.Id
    items = @get('lineItems')
    if !items? || items.length is 0 then return null
    i = _.find items, (item) -> item.suggestion._id == index
    if i? then return i
    items[index]
  calcTotal: ->
    total = 0
    total += li.total for li in @get 'lineItems'
    total
  setTotal: ->
    @set 'total', @calcTotal()


class exports.Request extends Shared.Request
  urlRoot: '/api/requests'



class exports.CustomerReview extends BB.BadassModel
  url: -> "/api/requests/#{@get('requestId')}/suggestion"
  # validation:
    # fullName:  { required: true }
    # email:     { required: true, pattern: 'email' }


class exports.ExpertReview extends BB.BadassModel
  url: -> "/api/requests/#{@get('requestId')}/suggestion"
  validation:
    expertStatus:         { required: true }
    expertFeedback:       { rangeLength: [50, 2000], msg: 'Supply min 50 chars so we can learn your preferences & get better at sending you the right opportunities. '}
    expertComment:        { rangeLength: [10, 2000], msg: "Leave a comment for the customer to build some rapport." }
    expertAvailability:   { required: true, msg: "Supply location / timezone & availability." }

module.exports = exports