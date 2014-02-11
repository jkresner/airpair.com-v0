ApiConfig = require '../../models/ApiConfig'
googleapis = require 'googleapis'
OAuth2Client = googleapis.OAuth2Client

# Doesn't support multiple versions of same API.
# Google will give you an error if you request an API with an account that
# doesnt have correct privileges.
class Google
  # map of email:AuthClient
  aclients: undefined

  # map of email:ApiConfig (access_token, refresh_token, etc)
  configs: undefined

  # map of email:access_token (the most recently seen one)
  lastSeen: {}

  # the googleapi client, passed back from discovery call
  client: undefined

  constructor: (oauth, cb) ->
    cb = cb || -> # usually this is undefined

    onError = (err) =>
      if !err then return
      stack = new Error('Google constructor: ' + err.message).stack
      console.log stack
      if cfg.isProd then winston.error stack
      return cb(err)

    query = name: 'googleapi'
    ApiConfig.find(query).lean().exec (err, configs) =>
      if err then return onError err
      @_createAuthClients(oauth, configs)
      @_createConfigMap(configs)
      @_discover(configs, cb)

  _createAuthClients: (oauth, configs) =>
    @aclients = {}
    # c.user is an email, e.g. 'team@airpair.com'
    for c in configs
      @aclients[c.user] =
        new OAuth2Client(oauth.CLIENT_ID, oauth.CLIENT_SECRET, oauth.REDIRECT_URL)
      @aclients[c.user].setCredentials(c.data.tokens)

  _createConfigMap: (configs) =>
    @configs = {}
    for c in configs
      @configs[c.user] = c

  # discover all unique APIs
  _discover: (configs, cb) ->
    apis = {
      # youtube: 'v3'
    }

    for c in configs
      # this is why it doesnt support multiple versions of the same API
      _.defaults(apis, c.data.discover)

    _.each apis, (version, name) ->
      googleapis.discover(name, version)

    if cfg.env is 'test'
      console.log 'google wrapper in test mode.'
      return cb && cb()

    googleapis.execute (err, client) =>
      if err
        stack = new Error('discovery: ' + err.message).stack
        console.log stack
        if cfg.isProd then winston.error stack
        return cb(err)
      @client = client
      cb(err, @)

  makeCall: (user, fn, cb) ->
    if !@client then return cb new Error 'Handshaking with Google, please wait'

    @getToken user, (err) =>
      if err then return cb err
      req = fn(@client) # e.g. (client) -> client.youtube.videos.list(params)
      req.withAuthClient(@aclients[user])
      req.execute (err, data) =>
        @setToken(user) # always want to set the token
        if err then return cb new Error err.message
        cb null, data

  # call this before every client call
  # goes to mongo, takes the latest access token
  getToken: (user, cb) =>
    # there should only ever be one matching object in the collection
    query =
      name: 'googleapi'
      user: user
    ApiConfig.findOne(query).lean().exec (err, doc) =>
      if err then return cb err
      doc = doc || {}
      access_token = doc.data.tokens.access_token
      @lastSeen[user] = access_token
      console.log 'trying to set from mongo:', access_token
      # when no token in DB, this does nothing
      @aclients[user].credentials.access_token = access_token
      cb()

  # call this after every client call
  # goes to mongo, saves the current access token as the latest one.
  setToken: (user) =>
    printErr = (err) =>
      if err then return console.log err.stack

    # googleapis lib might have changed it
    access_token = @aclients[user].credentials.access_token

    # it has never once been set in mongo, so no need to check&set
    if @lastSeen[user] == undefined
      query =
        'name': 'googleapi'
        'user': user
        'data.tokens.access_token': null
      ups = $set: 'data.tokens.access_token': access_token
      console.log 'new access_token', access_token
      return ApiConfig.update query, ups, printErr

    # it's the same, no need to save it back to mongo.
    if access_token == @lastSeen[user]
      console.log 'unchanged', @lastSeen[user]
      return

    # update mongo, but only if someone else didn't get to it first.
    # this is a check and set.
    query =
      'name': 'googleapi'
      'user': user
      'data.tokens.access_token': @lastSeen[user]
    ups = 'data.tokens.access_token': access_token

    console.log 'update', query, ups
    ApiConfig.update query, ups, printErr

  #
  # calls to specific API endpoints
  #
  videosList: (user, params, cb) ->
    part = 'id,snippet,contentDetails,fileDetails,liveStreamingDetails,player,processingDetails,recordingDetails,statistics,status,suggestions,topicDetails'
    params.part = params.part || part
    fn = (client) -> client.youtube.videos.list(params)
    @makeCall user, fn, cb

  createEvent: (user, params, body, cb) ->
    params = _.defaults params, cfg.google.calendar.params
    fn = (client) -> client.calendar.events.insert(params, body)
    @makeCall user, fn, cb

  patchEvent: (user, params, body, cb) ->
    # the properties in here that matter are eventId and sendNotifications
    params = _.defaults params, cfg.google.calendar.params
    fn = (client) -> client.calendar.events.patch(params, body)
    @makeCall user, fn, cb

module.exports = new Google(cfg.google.oauth)
