###
manual
- choose scopes
- choose get code
- enter code
- generate-google-refresh-token.js gives you your REFRESH_TOKEN, put it project

our project then does...
- discover APIs
- get client
- make API calls
- Auth will get an access token occasionally, need to save that to DB if you
  have more than one computer accessing the API, otherwise they invalidate
  eachother
###

_ = require 'underscore'
googleapis = require 'googleapis'
OAuth2Client = googleapis.OAuth2Client
AccessToken = require '../../models/accessToken'

module.exports = createClient = (cb) ->
  apis =
    calendar: 'v3'
    youtube: 'v3'
  # console.log 'cfg.google',cfg.google
  new Google(apis, cfg.google.oauth, cfg.google.tokens, cb)

class Google
  constructor: (apis, oauth, tokens, cb) ->
    # set up auth details
    googleapis.withAuthClient(
      new OAuth2Client(oauth.CLIENT_ID, oauth.CLIENT_SECRET, oauth.REDIRECT_URL)
    )
    googleapis.authClient.setCredentials(tokens)

    # discover apis
    _.each apis, (version, name) ->
      googleapis.discover(name, version)

    googleapis.execute (err, client) =>
      @client = client
      cb(err, @, client)

  # getter/setter style function
  _token: (access_token) ->
    if !access_token
      console.log 'get', googleapis.authClient.credentials.access_token
      return googleapis.authClient.credentials.access_token
    console.log 'set', access_token
    googleapis.authClient.credentials.access_token = access_token
    access_token

  # call this before every client call
  # goes to mongo, takes the latest access token
  getToken: (cb) ->
    # there should only ever be one object in the collection
    AccessToken.findOne {}, (err, doc) =>
      if err then return cb err
      doc = doc || {}
      @lastSeen = doc.access_token
      @_token doc.access_token # when no token in DB, this does nothing
      cb()

  # call this after every client call
  # goes to mongo, saves the current access token as the latest one.
  setToken: (cb) ->
    access_token = @_token() # googleapis lib might have changed this

    # it has never once been set in mongo, so no need to check&set
    if @lastSeen == undefined
      doc = access_token: access_token
      return new AccessToken(doc).save(cb)

    # it's the same, no need to save it back to mongo.
    if access_token == @lastSeen
      return cb()

    # update mongo, but only if someone else didn't get to it first.
    # this is a check and set.
    query = access_token: @lastSeen
    ups = access_token: access_token

    console.log 'update', query, ups
    AccessToken.update query, ups, cb

  #
  # calls to specific API endpoints
  #
  # sometimes googleapis calls back with an object instead of a `Error`.
  _formatError: (err) -> err.message || JSON.stringify(err, null, 2)
  createEvent: (body, cb) ->
    params = cfg.google.params

    @getToken (err) =>
      if err then return cb err

      @client.calendar.events.insert(params, body)
      .execute (err, data) =>
        if err then return cb new Error @_formatError(err)

        @setToken (err) =>
          if err then return cb err
          cb null, data

  videosList: (params, cb) ->
    part = 'id,snippet,contentDetails,fileDetails,liveStreamingDetails,player,processingDetails,recordingDetails,statistics,status,suggestions,topicDetails'
    params.maxResults = params.maxResults || 50
    params.part = params.part || part

    @getToken (err) =>
      if err then return cb err

      @client.youtube.videos.list(params)
      .execute (err, data) =>
        if err then return cb new Error @_formatError(err)

        @setToken (err) =>
          if err then return cb err
          cb(null, data)
