BB = require './../../lib/BB'
Shared = require './../shared/Models'
exports = {}


exports.User = Shared.User
exports.Skill = Shared.Skill
exports.CompanyContact = Shared.CompanyContact
exports.Request = Shared.Request

exports.Company = class Company extends Shared.Company

  populateFromGoogle: (user) ->
    if @get('contacts').length is 0
      @set _id: undefined, contacts: [{
        userId: user.get('_id')
        fullName: user.get('google').displayName
        email: user.get('google').emails[0].value
        gmail: user.get('google').emails[0].value
      }]

module.exports = exports