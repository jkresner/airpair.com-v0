AirConfSchedule = require '../services/airConfSchedule'
SettingsService = require '../services/settings'

class WorkshopsApi extends require('./_api')

  Svc: require './../services/workshops'

  routes: (app, route) ->
    app.get     "/api/#{route}/user", @loggedIn, @ap, @listByUser
    app.get     "/api/#{route}/:slug", @loggedIn, @ap, @detail
    app.get     "/api/adm/#{route}/refresh", @loggedIn, @admin, @ap, @refresh
    app.post    "/api/#{route}/:slug/attendees", @loggedIn, @ap, @createAttendee

  detail: (req) =>
    @svc.getWorkshopBySlug req.params.slug, @cbSend

  createAttendee: (req, res, next) =>
    if @data.userEmail?
      settings = new SettingsService(@usr)
      settings.getByEmail @data.userEmail, (err, user) =>
        @svc.addAttendee req.params.slug, user._id, @data.requestId, @cbSend
    else
      @svc.addAttendee req.params.slug, @data.userId, @data.requestId, @cbSend

  listByUser: =>
    @svc.getListByAttendee(null, @cbSend)

  refresh: =>
    AirConfSchedule.update(@cbSend)


module.exports = (app) -> new WorkshopsApi app, 'workshops'
