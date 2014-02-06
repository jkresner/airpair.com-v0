{owner2name} = require '../identity/roles'
google = require('./wrappers/google')
ONE_HOUR = 3600000 # milliseconds

owner2colorIndex =
  mi: undefined # default color for the calendar, #9A9CFF
  '': 1  # blue
  il: 2  # green
  '': 3  # purple
  ds: 4  # red
  '': 5  # yellow
  jk: 6  # orange
  '': 7  # turqoise
  '': 8  # gray
  '': 9  # bold blue
  dt: 10 # bold green
  '': 11 # bold red

capitalizeFirstLetter = (str) ->
  str[0].toUpperCase() + str.slice(1)

addTime = (original, milliseconds) ->
  new Date original.getTime() + milliseconds

class CalendarService
  google: google
  create: (request, call, cb) ->
    start = call.datetime
    owner = request.owner
    sug = _.find request.suggested, (s) -> s.expert._id == call.expertId
    expert = sug.expert
    expertName = capitalizeFirstLetter(expert.name.trim())
    expertFirst = expertName.slice(0, expertName.indexOf(' '))
    customerName = capitalizeFirstLetter(request.company.contacts[0].fullName.trim())
    customerFirst = customerName.slice(0, customerName.indexOf(' '))
    tag = request.tags[0]?.name || 'n/a'
    body =
      start:
        dateTime: start.toISOString()
      end:
        dateTime: addTime(start, call.duration * ONE_HOUR).toISOString()
      attendees: [
        { email: "#{owner}@airpair.com" }
        { email: request.company.contacts[0].email }
        { email: expert.email }
      ]
      summary: "Airpair #{customerFirst}+#{expertFirst} (#{tag})"
      colorId: owner2colorIndex[owner]
      description:
        """Your account manager, #{owner2name[owner]}, will set up a Google
        hangout for this session and share the link in the HipChat room a few
        minutes prior to the session.

        You are encouraged to make sure beforehand your mic/webcam are working
        on your system. Please let #{owner2name[owner]} know if you'd like to do
        a dry run."""

    # don't show test data up in people's calendars
    if !cfg || !cfg.isProd
      body.attendees = body.attendees.map (o) ->
        o.email = o.email.replace('@', 'AT') + '@example.com'
        o

    # only development and prod will make events, in their respective calendars
    if cfg.env is 'test'
      return cb null, { htmlLink: 'http://example.com/google-calendar-link' }

    @google.createEvent body, cb

  patch: (oldCall, newCall, cb) ->
    sameStart = oldCall.datetime.getTime() == newCall.datetime.getTime()
    sameDuration = oldCall.duration == newCall.duration
    if sameStart && sameDuration
      console.log 'datetime && duration unchanged'
      return process.nextTick ->
        cb null, oldCall.gcal

    params =
      eventId: oldCall.gcal.id
      sendNotifications: newCall.sendNotifications

    start = newCall.datetime
    body =
      start:
        dateTime: start.toISOString()
      end:
        dateTime: addTime(start, newCall.duration * ONE_HOUR).toISOString()

    # allow development to edit prod's calls, but don't update gcal
    # TODO wow so ugly.
    isTest = cfg?.env is 'test'
    isDevButNotOurs = cfg?.env is 'dev' &&
      oldCall.gcal.creator?.email == 'team@airpair.com'
    if !cfg || isTest || isDevButNotOurs
      fakeEventData = _.extend oldCall.gcal, body
      return process.nextTick -> cb null, fakeEventData

    @google.patchEvent params, body, cb

module.exports = new CalendarService()
