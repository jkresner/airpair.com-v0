async         = require 'async'
DomainService = require './_svc'
Roles         = require '../identity/roles'
RatesSvc      = require './rates'
SettingsSvc   = require './settings'
Order         = require '../models/order'
User          = require '../models/user'


module.exports = class RequestsService extends DomainService

  mailman: require '../mail/mailman'
  model: require '../models/request'
  rates: new RatesSvc()
  settingsSvc: new SettingsSvc()

  publicView: (request) ->
    r = _.pick request, ['_id','tags','company','brief','availability','owner']
    r.company = _.pick r.company, ['about']
    r.company.contacts = request.company.contacts.map (c) ->
      _.pick c, ['pic']
    r

  associatedView: (request) ->
    _.pick request, ['_id','tags','company','brief','availability','budget','pricing','suggested','owner']

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
    new @model(request).save (e, r) =>
      if e then $log 'request.create error:', e
      if e then return callback e
      @notifyAdmins(r)
      callback null, r

  getByIdSmart: (id, usr, callback) =>
    @model.findOne({ _id: id }).lean().exec (e, r) =>
      if e then return callback e
      request = null

      if r?
        if Roles.isAdmin usr
          request = r
          r.base = @rates.base
        else if Roles.isRequestExpert usr, r
          @addViewEvent r, usr, "expert view"
          request = @associatedView r
        else if Roles.isRequestOwner usr, r
          @addViewEvent r, usr, "customer view"
          request = r
        else
          @addViewEvent r, usr, "anon view"
          request = @publicView r

        for s in r.suggested
          s.suggestedRate = @rates.calcSuggestedRates r, s.expert

      callback null, request

  update: (id, data, callback) ->
    @model.findByIdAndUpdate(id, data).lean().exec (e, r) =>
      if e then return callback e
      @_setRatesForRequest r

      # copy owner and marketingTags to every associated order.
      updates = { marketingTags: r.marketingTags, owner: r.owner || '' }
      Order.update { requestId: id }, updates, multi: true, (err, numChanged) =>
        if err then return callback err
        callback(null, r)

  _setRatesForRequest: (request) ->
    for suggested in request.suggested
      suggested.suggestedRate =
        @rates.calcSuggestedRates request, suggested.expert
    request.base = @rates.base

  inboundSelect:
    '_id': 1
    'company.name': 1
    'company.contacts': { $slice: [0, 1] }
    'company.contacts.email': 1
    'company.contacts.fullName': 1
    'company.contacts.pic': 1
    'status': 1
    'owner': 1
    'calls.status': 1
    'suggested.expertStatus': 1
    'suggested.expert.pic': 1
    'tags.short': 1
    'calls.recordings.type': 1

  # Used for adm/inbound dashboard list
  getActive: (callback) ->
    @model.find({}, @inboundSelect)
      .where('status').in(['received','incomplete','review','scheduled','holding'])
      .lean()
      .exec (e, requests) =>
        if e then return callback e
        if !requests then requests = {}

        iterator = (receivedReq, cb) =>
          if receivedReq.owner # do not bother checking/setting prevOwner if owner is already set
            cb null
            return

          @model.find({}, @inboundSelect)
              .where('status').nin(['received'])
              .where('company.contacts.email' : receivedReq.company.contacts[0].email)
              .exec (e, prevRequests) =>
                if prevRequests && prevRequests[0]
                  receivedReq.prevOwner = prevRequests[0].owner

                cb null

        receivedList = _.filter(requests, (r) -> r.status == 'received')
        async.each receivedList, iterator, (err) =>
          if err then return callback err
          callback null, requests

  # Used for history
  getInactive: (callback) ->
    @model.find({}, @inboundSelect)
      .where('status').in(['canceled', 'completed'])
      .exec (e, r) ->
        if e then return callback e
        r = {} if r is null
        callback null, r

  getByCallId: (callId, callback) ->
    query = { 'calls._id': callId }
    @model.findOne(query)
      .exec (e, request) ->
        if e then return callback e
        if !request then request = {}
        callback null, request

  updateSuggestionByExpert: (request, usr, expertReview, callback) =>
    # TODO, add some validation!!
    # if expertReview.agree

    @settingsSvc.addPayPalSettings usr._id, expertReview.payPalEmail, (e, r) =>
      if e then $log 'save.settings error:', e, r

    ups = expertReview
    data = { suggested: request.suggested, events: request.events }
    sug = _.find request.suggested, (s) -> _.idsEqual s.expert.userId, usr._id
    sug.events.push @newEvent(usr, "expert updated")
    sug.expertRating = ups.expertRating
    sug.expertFeedback = ups.expertFeedback
    sug.expertComment = ups.expertComment
    sug.expertStatus = ups.expertStatus
    sug.expertAvailability = ups.expertAvailability
    sug.expert.paymentMethod =
      type: 'paypal', info: { email: expertReview.payPalEmail }
    data.events.push @newEvent(usr, "expert reviewed", ups)

    @update request._id, data, (e, updatedRequest) =>
      if e then return callback e
      @mailman.importantRequestEvent "expert reviewed #{ups.expertStatus}", usr, updatedRequest
      callback(null, updatedRequest)

  notifyAdmins: (model) ->
    tags = model.tags.map((o) -> o.short).join(' ')
    @mailman.sendEmailToAdmins
      templateName: "admNewRequest"
      subject: "New airpair request: #{model.company.contacts[0].fullName} #{model.budget}$"
      request: model
      tags: tags
      (e) ->
        if e then $log 'notifyAdmins error', e
