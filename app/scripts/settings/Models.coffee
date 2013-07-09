BB = require './../../lib/BB'
exports = {}


class exports.Settings extends BB.BadassModel

  url: -> '/api/settings'

  defaults:
    'paymentMethods': [ { type: 'paypal', isPrimary: true, info: {} } ]

  paymentMethod: (index) ->
    pms = @get('paymentMethods')
    if !pms? || pms.length is 0 then return null
    p = _.find pms, (o) -> o.type == index
    if p? then return p
    pms[index]


module.exports = exports