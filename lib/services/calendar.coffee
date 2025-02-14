# {owner2name} = require '../identity/roles'
# google       = require('./wrappers/google')
# ONE_HOUR     = 3600000 # milliseconds


# # https://developers.google.com/google-apps/calendar/v3/reference/colors/get
# owner2colorIndex =
#   ad: undefined # default color for the calendar, #9A9CFF
#   '': 1  #a4bdfc blue
#   il: 2  #7ae7bf green
#   '': 3  #dbadff purple
#   of: 4  #ff887c red
#   '': 5  #fbd75b yellow
#   jk: 6  #ffb878 orange
#   '': 7  #46d6db turqoise
#   du: 8  #e1e1e1 gray
#   '': 9  #5484ed bold blue
#   pg: 10 #51b749 bold green
#   '': 11 #dc2127 bold red

# capitalizeFirstLetter = (str) ->
#   str[0].toUpperCase() + str.slice(1)

# addTime = (original, milliseconds) ->
#   new Date original.getTime() + milliseconds

# class CalendarService
#   google: google
#   account: config.google.calendar.account

#   _getEventName: (request, expertId) ->
#     sug = _.find request.suggested, (s) -> _.idsEqual s.expert._id, expertId
#     expert = sug.expert
#     expertName = capitalizeFirstLetter(expert.name.trim())
#     expertFirst = expertName.slice(0, expertName.indexOf(' '))
#     customerName = capitalizeFirstLetter(request.company.contacts[0].fullName.trim())
#     customerFirst = customerName.slice(0, customerName.indexOf(' '))
#     tag = request.tags[0]?.name || 'n/a'
#     "Airpair #{customerFirst}+#{expertFirst} (#{tag})"

#   create: (request, call, cb) ->
#     params =
#       sendNotifications: call.sendNotifications

#     sug = _.find request.suggested, (s) -> _.idsEqual s.expert._id, call.expertId
#     start = call.datetime
#     owner = request.owner
#     body =
#       start:
#         dateTime: start.toISOString()
#       end:
#         dateTime: addTime(start, call.duration * ONE_HOUR).toISOString()
#       attendees: [
#         { email: "#{owner}@airpair.com" }
#         { email: request.company.contacts[0].email }
#         { email: sug.expert.email }
#       ]
#       summary: @_getEventName(request, call.expertId)
#       colorId: owner2colorIndex[owner]
#       description:
#         """Your account manager, #{owner2name[owner]}, will set up a Google
#         hangout for this session and share the link in the HipChat room a few
#         minutes prior to the session.

#         You are encouraged to make sure beforehand your mic/webcam are working
#         on your system. Please let #{owner2name[owner]} know if you'd like to do
#         a dry run.

#         Request: https://airpair.com/review/#{request._id}"""

#     # maksim & jonathon watch everything, so duplicate invites are annoying
#     if call.inviteOwner == false
#       body.attendees.shift()

#     # don't show test data up in people's calendars
#     if !config || !config.isProd
#       body.attendees = body.attendees.map (o) ->
#         o.email = o.email.replace('@', 'AT') + '@example.com'
#         o

#     # only development and prod will make events, in their respective calendars
#     if config.env is 'test'
#       return cb null, { htmlLink: 'http://example.com/google-calendar-link' }

#     @google.createEvent @account, params, body, cb

#   patch: (oldCall, newCall, cb) ->
#     sameStart = oldCall.datetime.getTime() == newCall.datetime.getTime()
#     sameDuration = oldCall.duration == newCall.duration

#     if sameStart && sameDuration
#       return process.nextTick ->
#         cb null, oldCall.gcal

#     params =
#       eventId: oldCall.gcal.id
#       sendNotifications: newCall.sendNotifications

#     start = newCall.datetime
#     body =
#       start:
#         dateTime: start.toISOString()
#       end:
#         dateTime: addTime(start, newCall.duration * ONE_HOUR).toISOString()

#     # allow development to edit prod's calls, but don't update gcal
#     # TODO wow so ugly.
#     isTest = config?.env is 'test'
#     isDevButNotOurs = config?.env is 'dev' &&
#       oldCall.gcal.creator?.email == 'team@airpair.com'
#     if !config || isTest || isDevButNotOurs
#       fakeEventData = _.extend oldCall.gcal, body
#       return process.nextTick -> cb null, fakeEventData

#     @google.patchEvent @account, params, body, cb


#   changeExpert: (request, call, expert, cb) ->

#     params =
#       eventId: call.gcal.id
#       sendNotifications: true

#     $log 'cal.changeExpert', params

#     body =
#       attendees: [
#         { email: "#{request.owner}@airpair.com" }
#         { email: request.company.contacts[0].email }
#         { email: expert.email }
#       ]
#       summary: @_getEventName(request, expert._id)

#     $log 'google cal body', body

#     # allow development to edit prod's calls, but don't update gcal
#     # TODO wow so ugly.
#     isTest = config?.env is 'test'
#     isDevButNotOurs = config?.env is 'dev' &&
#       call.gcal.creator?.email == 'team@airpair.com'
#     if !config || isTest || isDevButNotOurs
#       fakeEventData = _.extend call.gcal, body
#       return process.nextTick -> cb null, fakeEventData

#     $log 'google patching', @account

#     @google.patchEvent @account, params, body, cb


# module.exports = new CalendarService()

module.exports = {}
