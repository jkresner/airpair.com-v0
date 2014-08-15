AirConfSchedule = require '../services/airConfSchedule'
SettingsService = require '../services/settings'

json2csv = require 'json2csv'

class WorkshopsApi extends require('./_api')

  Svc: require './../services/workshops'

  routes: (app) ->
    app.get  "/adm/workshop/registrants", @loggedIn, @admin, @ap, @getAllRegisteredAirconfUsers
    app.get  "/adm/workshop/registrants.csv", @loggedIn, @admin, @ap, @getAllRegisteredAirconfUsersAsCSV
    app.get  "/adm/workshops/refresh", @loggedIn, @admin, @ap, @refresh
    app.get  "/workshops-for-user", @loggedIn, @ap, @listByUser
    app.get  "/workshops/:slug", @loggedIn, @ap, @detail # todo: obsolete?
    app.get  "/workshops/:slug/attendees", @loggedIn, @ap, @listAttendees
    app.post "/workshops/:slug/attendees", @loggedIn, @ap, @createAttendee

  detail: (req) =>
    @svc.getWorkshopBySlug req.params.slug, @cbSend

  createAttendee: (req, res, next) =>
    if @data.userEmail?
      # if an admin is manually adding a user to a session
      settings = new SettingsService(req.user)
      settings.getByEmail @data.userEmail, (err, user) =>
        @svc.addAttendee req.params.slug, user._id, @cbSend
    else
      # user is RSVP'ing for a workshop
      @svc.addAttendee req.params.slug, @data.userId, @cbSend

  listAttendees: (req, res, next) =>
    @svc.getAttendeesBySlug req.params.slug, @cbSend

  listByUser: (req, res, next) =>
    @svc.getListByAttendee(req.user._id, @cbSend)

  getAllRegisteredAirconfUsers: (req, res, next) =>
    @svc.getAllRegisteredAirconfUsers(@cbSend)

  getAllRegisteredAirconfUsersAsCSV: (req, res, next) =>
    @svc.getAllRegisteredAirconfUsers (err, users) =>
      json2csv data: users, fields: ['date','name', 'company', 'email','gplus','picture','revenue','rsvpCount','rsvpSessions'], (err, csv) =>
        @cbSend(err, csv)

  refresh: =>
    AirConfSchedule.update(@cbSend)


module.exports = (app) -> new WorkshopsApi(app)
