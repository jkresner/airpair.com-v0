{owner2name} = require '../identity/roles'
gcalCreate = require '../gcal/create'
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
      description: "Your account manager, #{owner2name[owner]} will set up a" +
        " google hangout for this session and invite you to it."

    gcalCreate body, cb
  # edit:

module.exports = new CalendarService()
