class WorkshopsApi extends require('./_api')

  Svc: require './../services/workshops'

  routes: (app, route) ->
    app.get     "/api/#{route}/user", @loggedIn, @ap, @listByUser
    app.get     "/api/#{route}/:slug", @loggedIn, @ap, @detail
    app.post    "/api/#{route}/:slug/attendees", @loggedIn, @ap, @createAttendee

  detail: (req) =>
    @svc.getWorkshopBySlug req.params.slug, @cbSend

  createAttendee: (req, res, next) =>
    @svc.addAttendee req.params.slug, @data.userId, @data.requestId, @cbSend

  listByUser: =>
    @svc.getListByAttendee(null, @cbSend)

module.exports = (app) -> new WorkshopsApi app, 'workshops'
