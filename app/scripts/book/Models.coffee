BB      = require './../../lib/BB'
Shared  = require './../shared/Models'
exports = {}


exports.User = Shared.User
exports.Expert = Shared.Expert

exports.Request = class Request extends Shared.Request

  # defaults:
  #   pricing: 'private'
  #   budget: 110

  # baseRates: [80,110,150,210,300]

  # opensource: -20

  # nda: 50

  # rates: (pricing) ->
  #   i = 0
  #   rates = []
  #   pricing = @get('pricing') if !pricing?
  #   for r in @baseRates
  #     if pricing is 'opensource' then rates.push r+@opensource
  #     else if pricing is 'nda' then rates.push r+@nda
  #     else rates.push r
  #     i++
  #   rates


module.exports = exports
