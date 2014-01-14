async           = require 'async'
DomainService   = require './_svc'
Roles           = require '../identity/roles'
RatesSvc        = require './rates'
SettingsSvc     = require './settings'
Order           = require '../models/order'


module.exports = class RequestsService extends DomainService

  mailman: require '../mail/mailman'
  model: require '../models/request'
  rates: new RatesSvc()
  settingsSvc: new SettingsSvc()

  publicView: (request) ->
    _.pick request, ['_id','tags','company','brief','availability','owner']

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

      callback null, request

  update: (id, data, callback) ->
    tasks = {}
    tasks.request = (cb) =>
      @model.findByIdAndUpdate(id, data).lean().exec (e, r) =>
        if e then return callback e
        for s in r.suggested
          s.suggestedRate = @rates.calcSuggestedRates r, s.expert
        cb(null, r)

    tasks.orders = (cb) =>
      @_copyOverMarketingTags id, data.marketingTags, cb

    async.parallel tasks, (err, results) ->
      if err then return callback err
      callback null, results.request

  # Used for dashboard
  getActive: (callback) ->
    @model.find({})
      .where('status').in(['received','incomplete','review','scheduled','holding'])
      .lean()
      .exec (e, rs) =>
        if e then return callback e
        rs = {} if rs is null
        for r in rs
          for s in r.suggested
            s.suggestedRate = @rates.calcSuggestedRates r, s.expert
          r.base = @rates.base
        callback null, rs

  # Used for history
  getInactive: (callback) ->
    @model.find({})
      .where('status').in(['canceled', 'completed'])
      .exec (e, r) ->
        if e then return callback e
        r = {} if r is null
        callback null, r


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

  _copyOverMarketingTags: (requestId, marketingTags, callback) ->
    query = { requestId: requestId }
    updates = { $set: { marketingTags: marketingTags } }
    options = multi: true
    Order.update query, updates, options, callback
