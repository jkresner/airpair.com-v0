DomainService   = require './_svc'

module.exports = class ExpertsService extends DomainService

  model: require './../models/expert'

  getById: (id, callback) =>
    query = if id is 'me' then userId: @usr._id else _id: id

    @searchOne query, {}, (e, r) =>
      if e? || r? then return callback e, r
      @searchOne {email: @usr.google._json.email}, {}, callback


  getByBookme: (urlSlug, callback) =>
    urlSlug = urlSlug.toLowerCase()
    @model.findOne({ 'bookMe.urlSlug': urlSlug, 'bookMe.enabled': true })
      .lean().exec (e, r) =>
        r = {} if !r || !r.bookMe || !r.bookMe.enabled
        callback e, r

  getByBookmeByUserId: (userId, callback) =>
    @model.findOne({ userId: userId, 'bookMe.enabled': true })
      .lean().exec (e, r) =>
        r = {} if !r || !r.bookMe || !r.bookMe.enabled
        callback e, r

  admSelect:
    'userId': 1
    'pic': 1
    'name': 1
    'username': 1
    'email': 1
    'gmail': 1
    'tags.short': 1
    'tags.name': 1
    'rate': 1
    'homepage': 1
    'gh.username': 1
    'gh.followers': 1
    'so.link': 1
    'so.reputation': 1
    'bb.id': 1
    'in.id': 1
    'tw.username': 1
    'sideproject': 1
    'other': 1

  # Used for adm/pipeline dashboard list
  getAll: (callback) ->
    query = rate: { $gt: 0 }
    options = lean: true
    @model.find query, @admSelect, options, (e, r) =>
      if e then return callback e
      if !r then r = []
      callback null, r

  update: (id, data, cb) =>
    if data.bookMe? && data.bookMe.enabled
      data.bookMe.urlSlug = data.bookMe.urlSlug.toLowerCase()
    super id, data, cb
