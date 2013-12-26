gcal = require './gcal'

params =
  # Air Pairings calendar ID
  calendarId: 'airpair.co_19t01n0gd6g7548k38pd3m5bm0@group.calendar.google.com',
  # TODO true if prod, false if dev
  sendNotifications: false

create = (body, cb) ->
  onCal = (err, cal, oauth2Client, cb) ->
    if err then return cb err

    cal.events.insert(params, body).withAuthClient(oauth2Client)
    .execute (err, data) ->
      # sometimes it calls back with an object instead of a `Error`.
      if err then cb new Error err.message || JSON.stringify(err, null, 2)
      cb null, data

  gcal onCal, cb

module.exports = create
