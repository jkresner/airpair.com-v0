gcal = require './gcal'

params =
  # Air Pairings calendar ID
  calendarId: 'airpair.co_19t01n0gd6g7548k38pd3m5bm0@group.calendar.google.com',
  # true if prod, false otherwise
  sendNotifications: false

if cfg? && cfg.isProd
  params.sendNotifications = true

create = (body, cb) ->
  onCal = (err, cal, oauth2Client) ->
    if err then return  err

    # WONTFIX set up a proper testing env.
    if !process.env.GCAL_ENV && (!cfg || !cfg.isProd)
      console.log 'gcal.create', params, body
      return cb null, htmlLink: 'http://example.com/google-calendar-link'

    cal.events.insert(params, body).withAuthClient(oauth2Client)
    .execute (err, data) ->
      # sometimes it calls back with an object instead of a `Error`.
      if err then return cb new Error err.message || JSON.stringify(err, null, 2)
      cb null, data

  gcal onCal

module.exports = create
