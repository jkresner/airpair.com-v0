authz            = require './../identity/authz'
loggedIn         = authz.LoggedIn isApi:true
admin            = authz.Admin isApi: true
SettingsSvc      = require './../services/settings'
SharedCardsSvc   = require './../services/settingsSharedCards'


class SettingsApi

  #DT what do you think cSend ("Check Send")... so much less code :)
  cSend: (res, next) ->
    (e, r) ->
      if e then return next e
      res.send r

  svc: new SettingsSvc()
  svcSharedCards: new SharedCardsSvc()

  constructor: (app) ->
    app.get     "/api/settings", loggedIn, @detail
    app.post    "/api/settings", loggedIn, @create
    app.put     "/api/settings", loggedIn, @update

    app.get     "/api/shared-cards/settings", admin, @detailSharedCards
    app.put     "/api/shared-cards/settings", admin, @updateSharedCards


  detail: (req, res, next) =>
    @svc.getByUserId req.user._id, @cSend(res,next)

  create: (req, res, next) =>
    @svc.create req.user._id, req.body, @cSend(res,next)

  update: (req, res, next) =>
    @svc.update req.user._id, @cSend(res,next)


  detailSharedCards: (req, res, next) =>
    @svcSharedCards.getSharedCards @cSend(res,next)

  updateSharedCards: (req, res, next) =>
    {stripeCreate,remove,share,unshare} = req.body
    if stripeCreate?
      @svcSharedCards.addCard req.body, @cSend(res,next)
    if remove?
      @svcSharedCards.removeCard req.body, @cSend(res,next)
    if share?
      @svcSharedCards.shareCard share.card._id, share.email, @cSend(res,next)
    if unshare?
      @svcSharedCards.unshareCard unshare.card._id, unshare.email, @cSend(res,next)


module.exports = (app) -> new SettingsApi app, 'settings'
