# ###
# we manually
# - choose scopes, run generate-google-refresh-token.js
# - get code
# - enter code
# - generate-google-refresh-token.js gives you your REFRESH_TOKEN, put in project

# our project then does...
# - discover APIs
# - get client
# - make API calls
# - Auth will get an access token occasionally, need to save that to DB if you
#   have more than one computer accessing the API, otherwise they invalidate
#   eachother
# ###
# googleapis = require 'googleapis'
# OAuth2Client = googleapis.OAuth2Client
# ExpertsAccessToken = require '../../models/expertsGoogleAccessToken'
# TeamAccessToken = require '../../models/teamGoogleAccessToken'

# # TODO refactor this whole thing cause it's nasty
# class Google
#   # TODO remove the command queue stuff b/c its not needed.
#   # for function calls that arrive before the discover call has returned
#   queue: []
#   constructor: (apis, oauth, tokens, model, cb) ->
#     @model = model
#     # set up auth details
#     googleapis.withAuthClient(
#       new OAuth2Client(oauth.CLIENT_ID, oauth.CLIENT_SECRET, oauth.REDIRECT_URL)
#     )
#     googleapis.authClient.setCredentials(tokens)

#     # discover apis
#     _.each apis, (version, name) ->
#       googleapis.discover(name, version)

#     if cfg.env is 'test'
#       console.log 'google wrapper in test mode.'
#       return cb && cb()

#     googleapis.execute (err, client) =>
#       if err
#         stack = new Error('discovery: ' + err.message).stack
#         console.log stack
#         if cfg.isProd then winston.error stack
#         return cb && cb(err)
#       @client = client
#       @clearQueue()
#       cb && cb(err, @, client)
#   clearQueue: ->
#     console.log 'clearQueue', @queue
#     @queue.forEach (item) ->
#       @[item[0]].apply(@, item[1])
#     @queue = []
#   # getter/setter style function
#   # TODO: make a PR to the google library that allows you to subscribe to
#   # access_token changes. Also publish our own version to npm, so we dont have
#   # to wait for them to merge. This will make our code WAY simpler.
#   _token: (access_token) ->
#     if !access_token
#       console.log 'get', googleapis.authClient.credentials.access_token
#       return googleapis.authClient.credentials.access_token
#     console.log 'set', access_token
#     googleapis.authClient.credentials.access_token = access_token
#     access_token

#   # call this before every client call
#   # goes to mongo, takes the latest access token
#   getToken: (cb) =>
#     # there should only ever be one object in the collection
#     @model.findOne {}, (err, doc) =>
#       if err then return cb err
#       doc = doc || {}
#       @lastSeen = doc.access_token
#       console.log 'trying to set from mongo:', doc.access_token
#       @_token doc.access_token # when no token in DB, this does nothing
#       cb()

#   # call this after every client call
#   # goes to mongo, saves the current access token as the latest one.
#   setToken: =>
#     printErr = (err) =>
#       if err then return console.log err.stack
#     access_token = @_token(null) # googleapis lib might have changed it

#     # it has never once been set in mongo, so no need to check&set
#     if @lastSeen == undefined
#       doc = access_token: access_token
#       console.log 'new access_token', access_token
#       return new @model(doc).save printErr

#     # it's the same, no need to save it back to mongo.
#     if access_token == @lastSeen
#       console.log 'unchanged', @lastSeen
#       return

#     # update mongo, but only if someone else didn't get to it first.
#     # this is a check and set.
#     query = access_token: @lastSeen
#     ups = access_token: access_token

#     console.log 'update', query, ups
#     @model.update query, ups, printErr

#   #
#   # calls to specific API endpoints
#   # TODO stop the silly repetition of getToken somecode setToken
#   #
#   createEvent: (body, cb) ->
#     if !@client then return @queue.push [ 'createEvent', arguments ]

#     params = _.clone cfg.google.calendar.params
#     @getToken (err) =>
#       if err then return cb err

#       @client.calendar.events.insert(params, body)
#       .execute (err, data) =>
#         @setToken() # always want to set the token
#         if err then return cb new Error err.message
#         cb null, data

#   patchEvent: (params, body, cb) ->
#     if !@client then return @queue.push [ 'patchEvent', arguments ]

#     # the properties in here that matter are eventId and sendNotifications
#     params = _.defaults params, cfg.google.calendar.params

#     @getToken (err) =>
#       if err then return cb err

#       @client.calendar.events.patch(params, body)
#       .execute (err, data) =>
#         @setToken() # always want to set the token
#         if err then return cb new Error err.message
#         cb null, data

#   videosList: (params, cb) ->
#     if !@client then return @queue.push [ 'videosList', arguments ]

#     part = 'id,snippet,contentDetails,fileDetails,liveStreamingDetails,player,processingDetails,recordingDetails,statistics,status,suggestions,topicDetails'
#     params.part = params.part || part
#     @getToken (err) =>
#       if err then return cb err

#       @client.youtube.videos.list(params)
#       .execute (err, data) =>
#         @setToken() # always want to set the token
#         if err then return cb new Error err.message
#         cb null, data

# # if !cfg? then require '../../util/appConfig'

# # making it a singleton prevents duplicate discovery calls
# apis =
#   calendar: 'v3'
#   youtube: 'v3'
# module.exports =
#   team: new Google(apis, cfg.google.oauth, cfg.google.tokens, TeamAccessToken)
#   experts: new Google(apis, cfg.google.oauth, cfg.google.expert_tokens, ExpertsAccessToken)

# # if !module.parent
# #   inspect = require('util').inspect
# #   createClient = module.exports

# #   mongoose = require 'mongoose'
# #   mongoose.connect cfg.mongoUri
# #   db = mongoose.connection
# #   db.on 'error', ->
# #     console.error.bind console, 'connection error:'
# #   db.once 'open', ->

# #     if process.argv[2] == 'yt'
# #       createClient (err, goog, _) ->
# #         if err then return console.log 'ready err', err.stack || err
# #         params = id: 'z1Z6xEYMYNY,d4QJDkdwLpc'
# #         goog.videosList params, (err, data) ->
# #           if err then return console.log 'dfgsgs', err.stack || err
# #           console.log 'vd', inspect(data, depth: null)

# #     if process.argv[2] == 'gc'
# #       createClient (err, goog, _) ->
# #         if err then return console.log 'ready err', err
# #         body =
# #           start: { dateTime: '2014-01-24T03:04:06.543Z' },
# #           end: { dateTime: '2014-01-24T05:04:06.543Z' },
# #           # attendees:
# #           #   [ { email: 'jkATairpair.com@example.com' },
# #           #   { email: 'kirkATstrobeck.com@example.com' },
# #           #   { email: 'qualls.jamesATgmail.com@example.com' } ]
# #           summary: 'Airpair Kirk+James (AngularJS)',
# #           # colorId: 6,
# #           description: 'hihi'

# #         goog.client.calendar.calendarList.list()
# #         .execute (err, data) ->
# #           if err then return console.log('cal', err.stack || err)
# #           console.log('callist', data)

# #           goog.client.calendar.events.insert(cfg.google.calendar.params, body)
# #           .execute (err, data) =>
# #             if err
# #               # again = ->
# #               #   goog.createEvent body, (err, data) ->
# #               #     if err then return console.log 'againerr', err.stack
# #               #     console.log 'againdata', data
# #               # setTimeout again, 1000
# #               return console.log 'dfgsgs', err.stack
# #             console.log 'vd', data
