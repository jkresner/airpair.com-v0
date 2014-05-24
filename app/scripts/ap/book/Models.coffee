BB      = require 'BB'
Shared  = require '../../shared/Models'
exports = {}

exports.User = Shared.User
exports.Expert = Shared.Expert
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


exports.Request = class Request extends Shared.Request

  urlRoot: '/api/requests/book'

  defaults:
    pricing: 'private'

  opensource: 0
  offline: 0
  private: 20
  nda: 70

  validation:
    userId:         { required: true }
    # company:        { required: true }
    brief:          { required: true, msg: 'Provide as much detail as possible (min one sentence / 80 chars) on what you want to work on.'}
    budget:         { required: true }
    availability:   { required: true, msg: 'Please detail your timezone, urgency & availability' }
    # tags:           { fn: 'validateNonEmptyArray', msg: 'At least one technology tag required' }


module.exports = exports
