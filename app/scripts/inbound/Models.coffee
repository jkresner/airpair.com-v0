BB      = require '../../lib/BB'
Shared  = require '../shared/Models'
exports = {}

exports.Expert = Shared.Expert

exports.Request = class Request extends Shared.Request
  getFarmData: ->
    hrRate: @get('budget') - @get('base')[@get('pricing')]
    month: new moment().format("MMM").toLowerCase()
    term: encodeURIComponent @tagsString()
    tagsString: @tagsString()

exports.Order = Shared.Order

module.exports = exports
