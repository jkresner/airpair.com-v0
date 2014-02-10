authz = require '../identity/authz'
admin = authz.Admin isApi: true
videos = require '../services/videos'

class VideosApi

  svc: videos

  constructor: (app, route) ->
    app.get "/api/#{route}/youtube/:youtubeId", admin, @fetchYouTube

  fetchYouTube: (req, res, next) =>
    @svc.fetchYouTube req.params.youtubeId, (err, videoData) =>
      if err?.message.indexOf('Forbidden') == 0 || err?.message.indexOf('Not Found') == 0
        return res.send data: youtube: err.message, 400
      if err then return next err
      res.send videoData

module.exports = (app) -> new VideosApi app, 'videos'
