BB = require './../../lib/BB'
Shared = require './../shared/Models'
exports = {}


exports.User = Shared.User
exports.Skill = Shared.Skill
exports.CompanyContact = Shared.CompanyContact
exports.Request = Shared.Request

exports.Company = class Company extends Shared.Company

  populateFromGoogle: (user) ->
    gplus = user.get('google')
    if @get('contacts').length is 0
      @set _id: undefined, contacts: [{
        userId:     user.get('_id')
        fullName:   gplus.displayName
        email:      gplus.emails[0].value
        gmail:      gplus.emails[0].value
        avatarUrl:  gplus._json.picture
      }]

module.exports = exports