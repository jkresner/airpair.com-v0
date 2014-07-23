exports = {}
BB      = require 'BB'
Shared  = require '../../shared/Models'

exports.User = Shared.User
exports.Settings = Shared.Settings

exports.Company = class Company extends Shared.Company

  populateFromGoogle: (user) ->
    if @get('contacts').length is 0
      gplus = user.get('google')
      @set _id: undefined, contacts: [{
        userId:     user.get('_id')
        fullName:   gplus.displayName
        email:      gplus.emails[0].value
        gmail:      gplus.emails[0].value
        pic:        gplus._json.picture
        timezone:   new Date().toString().substring(25, 45)
      }]


class exports.Order extends BB.BadassModel
  urlRoot: '/api/landing/airconf/order'
  defaults:
    total: 0
  setFromRequest: (request) ->
    @set
      lineItems: []
      requestId: request.id
      company:   request.get 'company'

    defaultPricing = request.get 'pricing'

    for s in request.get 'suggested'
      if s.expertStatus is 'available'
        # $log 'ss', s
        item =
        @get('lineItems').push
          suggestion: s
          qty: 0
          total: 0
          type: defaultPricing
          unitPrice: s.suggestedRate[defaultPricing].total

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



module.exports = exports
