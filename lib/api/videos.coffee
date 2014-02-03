authz = require '../identity/authz'
admin = authz.Admin isApi: true
videos = require '../services/videos'

class VideosApi

  svc: videos

  constructor: (app, route) ->
    app.get "/api/#{route}/youtube/:youtubeId", admin, @fetchFromYoutube
    # TODO need a new kind of user, something like "VideoAPIUser"
    app.get "/api/#{route}/:expertId", admin, @getByExpertId

  fetchFromYoutube: (req, res, next) =>
    @svc.fetch req.params.youtubeId, (err, videoData) =>
      if err && err.message.indexOf('Forbidden') == 0
        return res.send data: youtube: err.message, 400
      if err then return next err
      res.send videoData

  getByExpertId: (req, res, next) =>
    console.log 'list', req.params
    @svc.getByExpertId req.params.expertId, (e, r) ->
      if e then return next e
      res.send r

module.exports = (app) -> new VideosApi app, 'videos'
