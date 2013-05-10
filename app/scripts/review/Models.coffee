exports = {}
BB = require './../../lib/BB'
Shared = require './../shared/Models'


exports.User = Shared.User
exports.Request = Shared.Request


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