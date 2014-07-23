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


module.exports = exports
