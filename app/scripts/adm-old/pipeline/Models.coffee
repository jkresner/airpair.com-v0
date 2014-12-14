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
  parse: (data) ->
    for t in data.tags
      if !t.short? then t.short = t.slug
    if !data.availability then data.availability = "v1"
    if !data.pricing then data.pricing = "private"
    if !data.status then data.status = "received"
    if !data.events then data.events = []
    if !data.company then data.company = { contacts: [{userId: data.by.userId,pic: data.by.avatar,fullName:data.by.name,email:data.by.email,gmail:data.by.email}] }
    # $log('Request.parse', data)
    data

exports.Order = Shared.Order


exports.Room = class Room extends BB.BadassModel
  urlRoot: -> "/api/chat/rooms"


exports.RoomMember = class RoomMember extends BB.BadassModel
  url: ->
    "/api/chat/users/#{@get('email')}/#{@get('name').replace(' ','')}"


module.exports = exports
