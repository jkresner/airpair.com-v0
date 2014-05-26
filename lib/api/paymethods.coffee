
class PayMethodsApi extends require('./_api')

  Svc: require './../services/payMethods'

  routes: (app, route) ->
    app.get     "/api/#{route}", @admin, @ap, @list
    app.post    "/api/#{route}", @admin, @ap, @create
    app.put     "/api/#{route}/:id", @admin, @ap, @update
    app.delete  "/api/#{route}/:id", @admin, @ap, @delete


  create: (req, res) =>
    {token,email} = @data.stripeCreate
    @svc.create token, email, @cbSend

  update: (req, res) =>
    {share,unshare} = @data
    # $log 'update', share, unshare
    if share?
      @svc.share req.params.id, share.email, @cbSend
    if unshare?
      @svc.unshare req.params.id, unshare.email, @cbSend


module.exports = (app) -> new PayMethodsApi app, 'paymethods'
