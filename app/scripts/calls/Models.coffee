BB = require './../../lib/BB'
Shared = require './../shared/Models'

exports = {}

exports.Request = class Request extends Shared.Request
  urlRoot: '/api/requests'

exports.RequestCall = class RequestCall extends BB.BadassModel
  urlRoot: ->
    "/api/requests/#{@requestId}/calls"
  defaults:
    sendNotifications: true
    time: '12:00'

exports.Video = class VideoData extends BB.BadassModel
  urlRoot: ->
    "/api/videos/youtube/#{@youtubeId}"

exports.Order = Shared.Order

module.exports = exports
