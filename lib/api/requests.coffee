Api           = require './_api'
OrdersSvc     = require './../services/orders'
Roles         = require '../identity/roles'

class RequestApi extends Api

  logging:on

  Svc: require './../services/requests'
  oSvc: new OrdersSvc()

  routes: (app, route) ->
    app.get    "/api/#{route}/:id", @ap, @detail
    app.get    "/api/#{route}", @loggedIn, @ap, @list
    app.get    "/api/admin/#{route}/active", @admin, @ap, @active
    app.get    "/api/admin/#{route}/inactive", @admin, @ap, @inactive
    app.put    "/api/#{route}/:id", @loggedIn, @ap, @update
    app.put    "/api/#{route}/:id/suggestion", @loggedIn, @ap, @updateSuggestion
    app.post   "/api/#{route}", @loggedIn, @ap, @create
    app.post   "/api/#{route}/book", @loggedIn, @ap, @createBookme
    app.delete "/api/#{route}/:id", @admin, @ap, @delete


  list: (req, res) => @svc.getByUserId req.user._id, @cbSend
  active: (req, res) => @svc.getActive @cbSend
  inactive: (req, res) => @svc.getInactive @cbSend
  detail: (req, res) => @svc.getByIdSmart req.params.id, @cbSend
  createBookme: (req, res) => @svc.createBookme req.body, @cbSend

  update: (req, res) =>
    if @data.status is "canceled" && !@data.canceledDetail
      @tFE res, 'Update', 'canceledDetail', 'Must supply canceled reason'
    else if @data.status is "incomplete" && !@data.incompleteDetail
      @tFE res, 'Update', 'incompleteDetail', 'Must supply incomplete reason'
    else
      @svc.updateSmart req.params.id, @data, @cbSend

  updateSuggestion: (req, res) =>
    usr = req.user
    @svc.getById req.params.id, (e, r) =>

      if Roles.isRequestOwner(usr, r)
        return next new Error('Customer update suggestion not implemented')
      else if Roles.isRequestExpert(usr, r) && r.status == 'pending'
        @oSvc.confirmBookme r, usr, req.body, @cbSend
      else if Roles.isRequestExpert(usr, r)
        @svc.updateSuggestionByExpert r, @data, @cbSend
      else
        res.send 403


module.exports = (app) -> new RequestApi app, 'requests'
