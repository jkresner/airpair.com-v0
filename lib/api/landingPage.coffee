

class LandingPageApi extends require('./_api')

  Svc: require '../services/wrappers/stripe'

  routes: (app, route) ->
    app.get "/api/#{route}/bsa/:youtubeId", @ap, @fetchYouTube

    # make customer. save customer in firebase. charge customer. 


  fetchYouTube: (req, res, next) =>
    @svc.fetchYouTube req.params.youtubeId, (err, videoData) =>
      if err?.message.indexOf('Forbidden') == 0 || err?.message.indexOf('Not Found') == 0
        return res.send data: youtube: err.message, 400
      if err then return next err
      res.send videoData


module.exports = (app) -> new LandingPageApi app, 'landing'
