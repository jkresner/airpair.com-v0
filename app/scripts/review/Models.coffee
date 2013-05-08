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



module.exports = exports