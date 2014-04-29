CRUDApi    = require './_crud'
ExpertsSvc = require './../services/experts'
authz      = require './../identity/authz'
admin      = authz.Admin isApi: true
loggedIn   = authz.LoggedIn isApi: true
Roles      = authz.Roles
cSend      = require '../util/csend'

class ExpertApi extends CRUDApi

  model: require './../models/expert'
  svc: new ExpertsSvc()

  constructor: (app, route) ->
    app.get  "/api/#{route}", admin, @list
    super app, route

  list: (req, res, next) =>
    @svc.getAll cSend(res, next)

  detail: (req, res, next) =>

    search = '_id': req.params.id

    if req.params.id is 'me'
      search = userId: req.user._id

    @model.findOne search, (e, r) =>
      if r? then return res.send r
      else
        search = email: req.user.google._json.email
        $log 'detail req.user by email', search
        @model.findOne search, (e, r) =>
          if e then return next e
          r = {} if r is null
          res.send r

  update: (req, res, next) =>
    d = _.clone req.body
    if d.bookMe? && d.bookMe.enabled then d.bookMe.urlSlug = d.bookMe.urlSlug.toLowerCase()
    @svc.update d._id, d, cSend(res, next)


module.exports = (app) -> new ExpertApi app, 'experts'
