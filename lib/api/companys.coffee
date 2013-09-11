authz     = require './../identity/authz'
admin     = authz.Admin isApi: true


CRUDApi = require './_crud'


class CompanyApi extends CRUDApi

  model: require './../models/company'

  constructor: (app) ->
    app.get     "/api/company/me", @detail
    app.get     "/api/admin/companys", admin, @adminlist
    app.delete  "/api/companys/:id", admin, @delete

  detail: (req, res) =>

    search = '_id': req.params.id

    if req.params.id is 'me'
      search = 'contacts.userId': req.user._id
      #$log 'companyApi', search

    @model.findOne search, (e, r) ->
      r = {} if r is null
      res.send r

  delete: (req, res) =>
    @model.findByIdAndRemove req.params.id, (r) ->
      res.send r

  adminlist: (req, res) =>
    $log 'users.adminlist'
    @model.find {}, (e, r) -> res.send r


module.exports = (app) -> new CompanyApi app, 'companys'