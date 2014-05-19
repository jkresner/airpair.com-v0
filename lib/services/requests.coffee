async            = require 'async'
DomainService    = require './_svc'
Roles            = require '../identity/roles'
Order            = require '../models/order'
User             = require '../models/user'
RatesSvc         = require './rates'
SettingsSvc      = require './settings'
MarketingTagsSvc = require './marketingtags'
Query            = require './requests.query'


module.exports = class RequestsService extends DomainService

  mailman: require '../mail/mailman'
  model: require '../models/request'
  rates: new RatesSvc()
  settingsSvc: new SettingsSvc()
  mTagsSvc: new MarketingTagsSvc()


  """ Get a request, shapes viewData by viewer + logs view events """
  getByIdSmart: (id, usr, callback) ->
    @getById id, (e, r) =>
      if r?

        if Roles.isAdmin usr
          r.base = @rates.base

        else if Roles.isRequestExpert usr, r
          @addViewEvent r, usr, "expert view"
          r = Query.select r, 'associated'

        else if Roles.isRequestOwner usr, r
          @addViewEvent r, usr, "customer view"

        else
          @addViewEvent r, usr, "anon view"
          r = Query.select r, 'public'

        @rates.addRequestSuggestedRates r

      callback null, r

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
      @notifyAdmins(r, usr)
      callback null, r

  createBookme: (usr, request, callback) =>
    request.userId = usr._id
    request.events = [@newEvent(usr, "created")]
    request.status = 'pending'
    $log 'r1', request.suggested[0]
    d = { availability: [], expertStatus: 'waiting' }
    _.extend request.suggested[0], d
    new @model(request).save (e, r) =>
      $log 'r2', r.suggested[0].suggestedRate
      if e then $log 'request.create error:', e
      if e then return callback e
      @notifyAdmins(r, usr)
      callback null, r


  update: (id, data, callback) =>
    @model.findByIdAndUpdate(id, data).lean().exec (e, r) =>
      if e then return callback e
      @_setRatesForRequest r

      @mTagsSvc.copyToOrders id, r.marketingTags, r.owner, (err, numChanged) =>
        if err then return callback err
        callback null, r

  _setRatesForRequest: (request) ->
    for suggested in request.suggested
      suggested.suggestedRate =
        @rates.calcSuggestedRates request, suggested.expert
    request.base = @rates.base


  getForHistory: (id, callback) =>
    @model.find userId: id, @historySelect, callback



  # Used for adm/inbound dashboard list
  getActive: (callback) ->
    query = status: $in: ['received','incomplete','waiting','review','scheduling','scheduled','holding','consumed','deferred','pending']
    @model.find(query, @inboundSelect).lean().exec (e, requests) =>
      if e then return callback e
      if !requests then requests = {}

      receivedList = _.filter requests, (r) ->
        r.status == 'received' && !r.owner
      async.each receivedList, iterator, (err) =>
        if err then return callback err
        callback null, requests

    iterator = (receivedReq, cb) =>
      query =
        userId: receivedReq.userId
        status: $nin: ['received']
      @model.find query, 'owner': 1, (e, prevRequests) =>
        if e then return cb e
        if prevRequests && prevRequests[0]
          receivedReq.prevOwner = prevRequests[0].owner
        cb()

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
    # @settingsSvc.addPayPalSettings usr._id, expertReview.payPalEmail, (e, r) =>
      # if e then $log 'save.settings error:', e, r

    $log 'expertReview', expertReview?, usr._id
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

    if request.status == 'pending'
      if sug.expertStatus == 'available' then data.status = 'pending'
      if sug.expertStatus == 'abstained'
        data.canceledDetail = ups.expertComment + ups.expertFeedback
        data.status = 'canceled'
    # Thinking here is we still want to use the request with another experts so
    # maybe setting to 'canceled' is not the right thing to do ...

    @update request._id, data, (e, updatedRequest) =>
      if e then return callback e
      @mailman.importantRequestEvent "expert reviewed #{ups.expertStatus}", usr, updatedRequest
      callback null, updatedRequest

  notifyAdmins: (model, usr) ->
    fullName = usr.name
    if model.company? then fullName = model.company.contacts[0].fullName

    tags = model.tags.map((o) -> o.short).join(' ')
    @mailman.sendEmailToAdmins
      templateName: "admNewRequest"
      subject: "New airpair request: #{fullName} #{model.budget}$"
      request: model
      tags: tags
      (e) ->
        if e then $log 'notifyAdmins error', e
