authz            = require './../identity/authz'
loggedIn         = authz.LoggedIn isApi:true
admin            = authz.Admin isApi: true
PayMethodsSvc    = require './../services/payMethods'


class PayMethodsApi

  #DT what do you think cSend ("Check Send")... less code :)
  cSend: (res, next) ->
    (e, r) ->
      # $log 'cSend', 'e', e, 'r', r
      if e then return next e
      res.send r

  svc: new PayMethodsSvc()

  constructor: (app, route) ->
    app.get     "/api/#{route}", admin, @list
    app.post    "/api/#{route}", admin, @create
    app.put     "/api/#{route}/:id", admin, @update
    app.delete  "/api/#{route}/:id", admin, @delete

  list: (req, res, next) =>
    # @svc.seed (e,r) =>
    @svc.getAll @cSend(res,next)

  create: (req, res, next) =>
    {token,email} = req.body.stripeCreate
    @svc.create token, email, @cSend(res,next)

  update: (req, res, next) =>
    {share,unshare} = req.body
    if share?
      @svc.share req.params.id, share.email, @cSend(res,next)
    if unshare?
      @svc.unshare req.params.id, unshare.email, @cSend(res,next)

  delete: (req, res, next) =>
    @svc.delete req.params.id, @cSend(res,next)


module.exports = (app) -> new PayMethodsApi app, 'paymethods'
