BB      = require 'BB'
Shared  = require '../../shared/Models'
exports = {}

exports.Expert = Shared.Expert


exports.Request = class Request extends Shared.Request
  getFarmData: ->
    hrRate: @get('budget') - @get('base')[@get('pricing')]
    month: new moment().format("MMM").toLowerCase()
    term: encodeURIComponent @tagsString(true)
    tagsStr: @tagsString(true)


exports.Order = Shared.Order


exports.Room = class Room extends BB.BadassModel
  urlRoot: -> "/api/chat/rooms"


exports.RoomMember = class RoomMember extends BB.BadassModel
  url: ->
    "/api/chat/users/#{@get('email')}/#{@get('name').replace(' ','')}"


module.exports = exports
