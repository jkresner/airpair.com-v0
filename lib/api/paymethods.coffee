Api           = require './_api'

class PayMethodsApi extends Api

  Svc: require './../services/payMethods'

  routes: (app, route) ->
    app.get     "/api/#{route}", @admin, @ap, @list
    app.post    "/api/#{route}", @admin, @ap, @create
    app.put     "/api/#{route}/:id", @admin, @ap, @update
    app.delete  "/api/#{route}/:id", @admin, @ap, @delete

  list: (req, res) =>
    # @svc.seed (e,r) =>
    @svc.getAll @cbSend

  create: (req, res) =>
    {token,email} = @data.stripeCreate
    @svc.create token, email,  @cbSend

  update: (req, res) =>
    {share,unshare} = @data
    $log 'update', share, unshare
    if share?
      @svc.share req.params.id, share.email, @cbSend
    if unshare?
      @svc.unshare req.params.id, unshare.email, @cbSend

  delete: (req, res, next) =>
    @svc.delete req.params.id, @dSend(res, next)


module.exports = (app) -> new PayMethodsApi app, 'paymethods'
