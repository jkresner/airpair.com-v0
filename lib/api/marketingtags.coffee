
class MarketingTagsApi extends require('./_api')

  Svc: require '../services/marketingtags'

  routes: (app, route) ->
    app.get     "/api/#{route}", @admin, @ap, @list
    app.get     "/api/#{route}/:id", @admin, @ap, @detail
    app.post    "/api/#{route}", @admin, @ap, @create
    app.put     "/api/#{route}/:id", @admin, @ap, @update
    app.delete  "/api/#{route}/:id", @admin, @ap, @delete


module.exports = (app) -> new MarketingTagsApi app, 'marketingtags'
