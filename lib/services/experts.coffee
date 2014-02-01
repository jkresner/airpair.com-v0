DomainService   = require './_svc'

module.exports = class ExpertsService extends DomainService

  model: require './../models/expert'

  # getByBookme: (urlSlug, callback) =>
  #   @model.findOne({ 'bookMe.urlSlug': urlSlug }).lean().exec (e, r) =>
  #     return callback e if e then
  #     return callback null, {} if !r.bookMe || !r.bookMe.enabled
  #     callback null, r

  admSelect:
    '_id': 1
    'userId': 1
    'pic': 1
    'name': 1
    'username': 1
    'email': 1
    'gmail': 1
    'tags': 1
    'rate': 1
    'homepage': 1
    'gh.username': 1
    'so.link ': 1
    'bb.id': 1
    'in.id': 1
    'tw.username': 1
    'sideproject': 1
    'other': 1
    'tags.short': 1      # DT note this does not work, but selects whole subdoc


  # Used for adm/inbound dashboard list
  getAll: (callback) ->
    $log 'getAll.experts'
    @model.find({}, @admSelect)
      .where('rate').gte(0)
      .lean()
      .exec (e, r) =>
        if e then return callback e
        if !r then r = []
        callback null, r
