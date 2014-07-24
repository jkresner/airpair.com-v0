class MatchersApi extends require('./_api')

  Svc: require('./../services/autoMatcher')

  routes: (app) ->
    app.get  "/api/match/tags", @loggedIn, @ap, (req) =>
      tags = req.param('tags').split(',')
      @svc.getMatches tags, req.query.budget, req.query.pricing, @cbSend

module.exports = (app) -> new MatchersApi(app)
