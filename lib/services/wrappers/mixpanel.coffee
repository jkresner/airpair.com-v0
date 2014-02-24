request = require 'superagent'
buildURL = require('mixpanel-helper')(cfg.analytics.mixpanel)

makeCall = (path, params, cb) ->
  uri = 'http://mixpanel.com/api/2.0/' + path
  if path == 'export'
    uri = 'https://data.mixpanel.com/api/2.0/export'

  url = buildURL uri, params

  request.get(url).end (err, res) =>
    if err then return cb err
    return cb null, res.body

makeCall.eventsFor = (email, cb) =>
  params = where: 'properties["$email"]=="' + email + '"'
  makeCall 'engage', params, (err, data) =>
    if err then return cb err
    # console.log JSON.stringify data, null, 2

    person = data.results[0]
    created = person.$properties.$created
    distinct_id = person.$distinct_id

    params =
      from_date: created.slice 0, 10
      to_date:  (new Date()).toISOString().slice 0, 10
      distinct_ids: [ distinct_id ]
      # where: distinct_ids: distinct_id

    makeCall 'stream/query', params, cb

makeCall.firstEvent = (data) =>
  data?.results?.events?[0]


makeCall.sanitizeForMongo = sanitizeForMongo = (data) =>
  if _.isArray data
    return data.map sanitizeForMongo

  if _.isObject data
    clean = {}
    _.each data, (value, dirtyKey) ->
      key = dirtyKey
      if key[0] == '$' then key = 'X' + key.slice(1)
      clean[key] = sanitizeForMongo value
    return clean

  return data

module.exports = makeCall

# if !module.parent
#   mp = module.exports
#   # distinct_id = '1444d01231f554-0f00e02d4-117a373b-fa000-1444d012320e9b'
#   email = "davidlbrundige@gmail.com"
#   params = where: 'properties["$email"]=="'+email+'"' # distinct_id: distinct_id

#   mp.eventsFor email, (err, events) =>
#     if err then return console.log err
#     console.log JSON.stringify events, null, 2
#     console.log 'firstEvent', mp.firstEvent events

#     console.log 'yay', JSON.stringify(sanitizeForMongo(events), null, 2)
