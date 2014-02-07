authz = require '../identity/authz'
admin = authz.Admin isApi: true
videos = require '../services/videos'

class VideosApi

  svc: videos

  constructor: (app, route) ->
    app.get "/api/#{route}/youtube/:youtubeId", admin, @fetchFromYoutube

    # TODO need a new kind of user, something like "VideoAPIUser"
    # TODO dont do this here lol
    app.get "/api/so/:soId*", admin, @getBySoId

  fetchYouTube: (req, res, next) =>
    @svc.fetchYouTube req.params.youtubeId, (err, videoData) =>
      if err?.message.indexOf('Forbidden') == 0 || err?.message.indexOf('Not Found') == 0
        return res.send data: youtube: err.message, 400
      if err then return next err
      res.send videoData

  getBySoId: (req, res, next) =>
    console.log 'getBySoId', req.params
    @svc.getBySoId req.params.soId, (e, r) ->
      if e then return next e
      res.send r

module.exports = (app) -> new VideosApi app, 'videos'
