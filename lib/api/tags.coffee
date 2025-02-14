
class TagsApi extends require('./_api')

  Svc: require './../services/tags'

  routes: (app) ->
    app.get     "/tags", @loggedIn, @ap, @list
    app.post    "/tags", @loggedIn, @ap, @create
    app.put     "/tags/:id", @loggedIn, @ap, @update
    app.delete  "/tags/:id", @loggedIn, @ap, @delete


  create: (req, res, next) => @svc.create @data.addMode, @data, (e, r) =>
    if e?
      @tFE res, 'Tag import', 'name', e
    else
      @cSend(res, next)(e,r)


module.exports = (app) -> new TagsApi(app)
