DomainService   = require './_svc'
RequestService  = require './requests'
RatesService    = require './rates'

module.exports = class ExpertsService extends DomainService

  #logging: on

  model: require './../models/expert'

  # Used for adm/pipeline dashboard list
  getAll: (cb) ->
    @searchMany { rate: { $gt: 0 } }, { fields: @admSelect }, cb


  getById: (id, callback) =>
    query = if id is 'me' then userId: @usr._id else _id: id

    @searchOne query, {}, (e, r) =>
      if e? || r? then return callback e, r
      @searchOne {email: @usr.google._json.email}, {}, (ee,rr) =>
        if !rr? then rr = {}
        callback ee, rr

  getBySubscriptions: (tagId, level, cb) =>
    @searchMany { tags: { $elemMatch: { '_id': tagId, 'subscription.auto': { $elemMatch: { $in: [level] } } } } }, { fields: @admSelect }, cb

  getByTagsAndMaxRate: (soTagIds, maxRate, cb) =>
    @searchMany { tags: { $elemMatch: { soId: { $in: soTagIds } } },  rate: { $lt: maxRate } }, {}, cb

  detailOnRequest: (id, cb) =>
    @searchOne userId: @usr._id, {}, (e, expert) =>
      if !expert? then return cb e, {}
      new RequestService(@usr).getById id, (ee, request) =>
        expert.suggestedRate = new RatesService().calcSuggestedRates request, expert
        cb ee, expert

  automatch: (tags, cb) =>
    console.log 'tags', arguments
    @getByTagsAndMaxRate tags.split(','), 150, (err, experts) ->
      cb err, experts


  getByBookme: (urlSlug, code, cb) =>
    urlSlug = urlSlug.toLowerCase()
    query = 'bookMe.urlSlug': urlSlug, 'bookMe.enabled': true
    @searchOne query, {}, (e, r) ->
      if !r || !r.bookMe || !r.bookMe.enabled then r = {}
      else
        if code?
          r.bookMe.code = "invalid code"
          for coupon in r.bookMe.coupons
            if coupon.code == code
              r.bookMe.code = code
              r.bookMe.rate = coupon.rate
        delete r.bookMe.coupons  # don't show coupons to customers
        # turns out we need the rake for later in the flow... need to look at this
        # for a nicer solution
        # delete r.bookMe.rake  # don't show rake to customers
      cb e, r


  # when an expert is looking at their own book me details
  getByBookmeByUserId: (userId, cb) =>
    @searchOne { userId: userId, 'bookMe.enabled': true }, {}, (e, r) =>
      r = {} if !r || !r.bookMe || !r.bookMe.enabled
      cb e, r

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


  update: (id, data, cb) =>
    if data.bookMe? && data.bookMe.enabled
      data.bookMe.urlSlug = data.bookMe.urlSlug.toLowerCase()
    super id, data, cb
