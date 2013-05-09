exports = {}
BB = require './../../lib/BB'
Shared = require './../shared/Models'


exports.User = Shared.User
exports.Request = Shared.Request


class exports.Suggestion extends BB.BadassModel
  url: -> "/api/requests/#{@get('requestId')}/suggestion"
  # validation:
    # fullName:  { required: true }
    # email:     { required: true, pattern: 'email' }

class exports.SuggestionExpert extends BB.BadassModel
  url: -> "/api/requests/#{@get('requestId')}/suggestion"
  validation:
    expertStatus:         { required: true }
    expertFeedback:       { rangeLength: [50, 2000], msg: 'We want to learn your preferences & only send you challenges you like to solve. Supply min 50 chars feedback.'}
    expertComment:        { rangeLength: [10, 2000], msg: "Build rapport. Let them know why you should (or won't) do this airpair. There may be a another opportunity around the corner!" }
    expertAvailability:   { required: true, msg: "Supply location / timezone & availability." }

module.exports = exports