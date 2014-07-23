class MatchersApi extends require('./_api')

  Svc: require('./../services/autoMatcher')

  routes: (app) ->
    app.get  "/api/match/tags/:tags", @loggedIn, @ap, (req) =>
      @svc.getMatches req.params.tags.split(','), req.query.budget, req.query.pricing, @cbSend

module.exports = (app) -> new MatchersApi(app)
