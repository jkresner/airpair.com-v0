Api           = require './_api'
OrdersSvc     = require './../services/orders'
Roles         = require '../identity/roles'
moment        = require 'moment-timezone'

class RequestApi extends Api

  # logging:on

  Svc: require './../services/requests'

  routes: (app) ->
    app.get    "/requests", @loggedIn, @ap, @list
    app.get    "/requests/:id", @ap, @detail
    app.get    "/requests/expert/:expertId", @loggedIn, @ap, @expertList
    app.get    "/admin/requests/active", @admin, @ap, @active
    app.get    "/admin/requests/inactive", @admin, @ap, @inactive
    app.get    "/admin/requests/inactive", @admin, @ap, @inactive
    app.get    "/admin/requests/:sddmmyy/:eddmmyy", @admin, @ap, @getByDates
    app.put    "/requests/:id", @loggedIn, @ap, @update
    app.put    "/requests/:id/suggestion", @loggedIn, @ap, @updateSuggestion
    app.post   "/requests/:id/suggestion", @loggedIn, @ap, @addSelfSuggestion
    app.post   "/requests", @loggedIn, @ap, @create
    app.post   "/requests/book", @loggedIn, @ap, @createBookme
    app.delete "/requests/:id", @admin, @ap, @delete

    app.get    "/reports/requests/experts/tagged", @admin, @ap, @taggedExpertsRequestsReport
    app.get    "/reports/requests/events", @admin, @ap, @requestEventsReport

  list: (req) => @svc.getByUserId req.user._id, @cbSend
  expertList: (req) => @svc.getBySuggestedExpert req.params.expertId, @cbSend
  active: (req) => @svc.getActive @cbSend
  inactive: (req) => @svc.getInactive @cbSend
  detail: (req) => @svc.getByIdSmart req.params.id, @cbSend
  createBookme: (req) => @svc.createBookme @data, @cbSend
  addSelfSuggestion: (req) => @svc.addSelfSuggestion req.params.id, @data, @cbSend

  getByDates: (req) =>
    start = moment req.params.sddmmyy, "YYYY-MM-DD"
    end = moment req.params.eddmmyy, "YYYY-MM-DD"
    @svc.getByDates start, end, @cbSend

  taggedExpertsRequestsReport: (req) =>
    @svc.listAllAvailableExpertsByTags @cbSend

  requestEventsReport: (req) =>
    console.log "*************************\n\n\n\n\n"
    @svc.requestEventsReport @cbSend

  update: (req, res) =>
    if @data.status is "canceled" && !@data.canceledDetail
      @tFE res, 'Update', 'canceledDetail', 'Must supply canceled reason'
    else if @data.status is "incomplete" && !@data.incompleteDetail
      @tFE res, 'Update', 'incompleteDetail', 'Must supply incomplete reason'
    else
      @svc.updateSmart req.params.id, @data, @cbSend

  updateSuggestion: (req, res, next) =>
    usr = req.user
    @svc.getById req.params.id, (e, r) =>

      if Roles.isRequestOwner(usr, r)
        next new Error 'Customer update suggestion not implemented'
      else if Roles.isRequestExpert(usr, r) && r.status == 'pending'
        new OrdersSvc(@svc.usr).confirmBookme r, @data, @cbSend
      else if Roles.isRequestExpert(usr, r)
        @svc.updateSuggestionByExpert r, @data, @cbSend
      else if @data.expert._id? && !Roles.isRequestExpert(usr, r)
        @svc.addSelfSuggestionByExpert r, @data, @cbSend
      else
        res.send 403


module.exports = (app) -> new RequestApi(app)
