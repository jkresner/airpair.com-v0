BB = require './../../lib/BB'
Shared = require './../shared/Models'
exports = {}


exports.User = Shared.User
exports.CompanyContact = Shared.CompanyContact

exports.Request = class Request extends Shared.Request

  defaults:
    pricing: 'private'
    budget: 110

  baseRates: [80,110,150,210,300]

  opensource: -20

  nda: 50

  rates: (pricing) ->
    i = 0
    rates = []
    pricing = @get('pricing') if !pricing?
    for r in @baseRates
      if pricing is 'opensource' then rates.push r+@opensource
      else if pricing is 'nda' then rates.push r+@nda
      else rates.push r
      i++
    rates

exports.Company = class Company extends Shared.Company

  populateFromGoogle: (user) ->
    gplus = user.get('google')
    if @get('contacts').length is 0
      @set _id: undefined, contacts: [{
        userId:     user.get('_id')
        fullName:   gplus.displayName
        email:      gplus.emails[0].value
        gmail:      gplus.emails[0].value
        pic:        gplus._json.picture
        timezone:   new Date().toString().substring(25, 45)
      }]

module.exports = exports