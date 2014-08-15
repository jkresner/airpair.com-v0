
class PayMethodsApi extends require('./_api')

  Svc: require './../services/payMethods'

  routes: (app) ->
    app.get     "/paymethods", @admin, @ap, @list
    app.post    "/paymethods", @admin, @ap, @create
    app.put     "/paymethods/:id", @admin, @ap, @update
    app.delete  "/paymethods/:id", @admin, @ap, @delete


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


module.exports = (app) -> new PayMethodsApi(app)
