DomainService   = require './_svc'

module.exports = class ExpertsService extends DomainService

  model: require './../models/expert'


  getByBookme: (urlSlug, callback) =>
    urlSlug = urlSlug.toLowerCase()
    @model.findOne({ 'bookMe.urlSlug': urlSlug, 'bookMe.enabled': true })
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
