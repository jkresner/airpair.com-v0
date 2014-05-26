
class VideosApi extends require('./_api')

  Svc: require '../services/videos'

  routes: (app, route) ->
    app.get "/api/#{route}/youtube/:youtubeId", @admin, @ap, @fetchYouTube


  fetchYouTube: (req, res, next) =>
    @svc.fetchYouTube req.params.youtubeId, (err, videoData) =>
      if err?.message.indexOf('Forbidden') == 0 || err?.message.indexOf('Not Found') == 0
        return res.send data: youtube: err.message, 400
      if err then return next err
      res.send videoData


module.exports = (app) -> new VideosApi app, 'videos'
