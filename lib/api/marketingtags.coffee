
class MarketingTagsApi extends require('./_api')

  Svc: require '../services/marketingtags'

  routes: (app) ->
    app.get     "/marketingtags", @admin, @ap, @list
    app.get     "/marketingtags/:id", @admin, @ap, @detail
    app.post    "/marketingtags", @admin, @ap, @create
    app.put     "/marketingtags/:id", @admin, @ap, @update
    app.delete  "/marketingtags/:id", @admin, @ap, @delete


module.exports = (app) -> new MarketingTagsApi(app)
