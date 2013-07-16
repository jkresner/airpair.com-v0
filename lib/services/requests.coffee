DomainService   = require './_svc'
Roles           = require './../identity/roles'
RatesSvc        = require './rates'

module.exports = class RequestsService extends DomainService

  model: require './../models/request'
  rates: new RatesSvc()

  publicView: (request) ->
    _.pick request, ['_id','tags','company','brief','availability']

  associatedView: (request) ->
    _.pick request, ['_id','tags','company','brief','availability','budget','pricing','suggested']


  # log event when the request is viewed
  addViewEvent: (request, usr, evtName) =>
    evt = @newEvent usr, evtName
    up = { events: _.clone(request.events) }
    up.events.push evt
    if evt.name is "expert view"
      up.suggested = request.suggested
      sug = _.find request.suggested, (s) -> _.idsEqual s.expert.userId, evt.by.id
      sug.events.push @newEvent(usr, "viewed")
    @model.findByIdAndUpdate request._id, up, (e, r) ->

  create: (usr, request, callback) =>
    request.userId = usr._id
    request.events = [@newEvent(usr, "created")]
    request.status = 'received'
    new @model( request ).save (e, r) ->
      if e then $log 'e', e
      callback r

  getByIdSmart: (id, usr, callback) =>
    @model.findOne({ _id: id }).lean().exec (e, r) =>
      request = null

      if r?
        if Roles.isRequestExpert usr, r
          @addViewEvent r, usr, "expert view"
          request = @associatedView r
        else if Roles.isRequestOwner usr, r
          @addViewEvent r, usr, "customer view"
          request = r
        else if Roles.isAdmin usr
          request = r
        else
          @addViewEvent r, usr, "anon view"
          request = @publicView r

        for s in r.suggested
          s.suggestedRate = @rates.calcSuggestedRates r, s.expert

      callback request

  update: (id, data, callback) ->
    @model.findByIdAndUpdate(id, data).lean().exec (e, r) =>
      for s in r.suggested
        s.suggestedRate = @rates.calcSuggestedRates r, s.expert

      callback r

  # Used for dashboard
  getActive: (callback) ->
    @model.find({})
      .where('status').in(['received', 'incomplete', 'review', 'scheduled'])
      .lean()
      .exec (e, rs) =>
        rs = {} if rs is null
        for r in rs
          for s in r.suggested
            s.suggestedRate = @rates.calcSuggestedRates r, s.expert
        callback rs

  # Used for history
  getInactive: (callback) ->
    @model.find({})
      .where('status').in(['canceled', 'completed'])
      .exec (e, r) ->
        r = {} if r is null
        callback r
