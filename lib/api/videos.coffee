authz = require '../identity/authz'
admin = authz.Admin isApi: true
videos = require '../services/videos'

class VideosApi

  svc: videos

  constructor: (app, route) ->
    app.get "/api/#{route}/youtube/:youtubeId", admin, @fetchFromYoutube

  fetchFromYoutube: (req, res, next) =>
    @svc.fetch req.params.youtubeId, (err, videoData) =>
      if err then return next err
      res.send videoData

module.exports = (app) -> new VideosApi app, 'videos'
