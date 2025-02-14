async            = require 'async'
Data             = require './requests.query'
Roles            = require '../identity/roles'
DomainService    = require './_svc'
RatesSvc         = require './rates'
SettingsSvc      = require './settings'
MarketingTagsSvc = require './marketingtags'
Mixpanel         = require './mixpanel'
expertPick       = require '../mix/expertForSuggestion'
objectIdWithTimestamp = require '../mix/objectIdWithTimestamp'


module.exports = class RequestsService extends DomainService

  # logging:on

  mailman:      require '../mail/mailman'
  model:        require '../models/request'
  rates:        new RatesSvc()
  settingsSvc:  new SettingsSvc()
  mTagsSvc:     new MarketingTagsSvc()


  getForHistory: (id, cb) =>
    userId = if id? && Roles.isAdmin(@usr) then id else @usr._id
    @searchMany {userId}, { fields: Data.view.history }, cb


  getByCallId: (callId, cb) -> @searchOne { 'calls._id': callId }, {}, cb

  getBySuggestedExpert: (expertId, callback) =>
    query = suggested:
      $elemMatch:
        'expert._id': expertId
    @searchMany query, {}, (error, requests) ->
      callback error, requests

  """ Used for adm/inbound dashboard inactive """
  getInactive: (cb) ->
    @searchMany Data.query.inactive, { fields: Data.view.pipeline }, cb

  # Show the previous account manager
  _getPreviousOwner: (request, cb) =>
    query = userId: request.userId, status: $nin: ['received']
    @model.find query, 'owner': 1, (e, r) =>
      if r && r[0] then request.prevOwner = r[0].owner
      cb e, r

  """ Used for adm/inbound dashboard list """
  getActive: (cb) ->
    @searchMany Data.query.active, { fields: Data.view.pipeline }, (e, requests) =>
      if e? then return cb e
      received = _.filter requests, (r) -> r.status == 'received' && !r.owner
      async.each received, @_getPreviousOwner, (er) => cb er, requests

  """ Used for growth reports """
  getByDates: (startUtc, endUtc, cb) =>

    query =
      _id:
        $gt: objectIdWithTimestamp(startUtc.toDate())
        $lt: objectIdWithTimestamp(endUtc.toDate())

    @searchMany query, { fields: Data.view.pipeline },(e,r) =>
      if e then console.log "ERROR", e else
        # $log 'RESULT: ', r.length
        cb e, r


  """ Get a request, shapes viewData by viewer + logs view events """
  getByIdSmart: (id, cb) ->
    @getById id, (e, r) =>
      if r?
        if Roles.isRequestExpert(@usr, r) && !Roles.isAdmin(@usr, r)
          @_addViewEvent r, "expert view"
          @rates.addRequestSuggestedRates r #important to get rates before strip query
          r = Data.select r, 'associated'
          cb e, r
        else if Roles.isAdmin @usr
          @rates.addRequestSuggestedRates r, true
          # async.each r.company.contacts, (contact, callback) =>
          #   Mixpanel.addProperties contact.email, contact, (error, request) =>
          #     callback e, contact
          # , (error, contacts) =>
          #   cb error, r
          cb e, r
        else if Roles.isRequestOwner @usr, r
          @_addViewEvent r, "customer view"
          @rates.addRequestSuggestedRates r, true
          cb e, r
        else if @usr?
          @_addViewEvent r, "unassigned view"
          r = Data.select r, 'associated'
          cb e, r
        else
          @_addViewEvent r, "anon view"
          r = Data.select r, 'public'
          cb e, r
      else
        cb e, r


  # log event when the request is viewed
  _addViewEvent: (request, evtName) =>
    up = events: _.clone(request.events)
    up.events.push @newEvent evtName
    if evtName is "expert view"
      up.suggested = request.suggested
      sug = _.find request.suggested, (s) => _.idsEqual s.expert.userId, @usr._id
      sug.expertStatus = 'opened' if sug.expertStatus == 'waiting'
      sug.events.push @newEvent "viewed"
    @model.findByIdAndUpdate request._id, up, ->



  """ Create a request by get help flow """
  create: (request, cb) =>
    defaults =
      userId: @usr._id
      events: [@newEvent "created"]
      status: 'received'
    super _.extend(request, defaults), (e, r) =>
      if r? then @mailman.admNewRequest r
      cb e, r




  """ Create a request by book direct flow """
  createBookme: (request, cb) =>
    defaults =
      userId: @usr._id
      events: [@newEvent "created"]
      status: 'pending'

    # not 100% sure why we're doing this..
    _.extend request.suggested[0], { availability: [], expertStatus: 'waiting' }

    new @model( _.extend(request, defaults) ).save (e,r) =>
      if e && @logging then $log 'svc.create', o, e
      if r? then @mailman.admNewRequest r
      cb e, r


  """ Log events when certain updates occur """
  updateSmart: (id, data, cb) ->
    {status,owner} = data
    @getById id, (e, r) =>
      evts = []

      # stop users updating other users requests (need a better solution!)
      if !(Roles.isAdmin(@usr, r) || Roles.isRequestOwner(@usr, r))
        return @unauthorized 'Request update', callback

      if status is "holding" && (!owner?||owner=='')
        evts.push @newEvent "sent received mail"
        data.owner = Roles.getAdminInitials @usr.google.id

      else if r.status != status
        evts.push @newEvent status

      # add a new suggestion
      for s in data.suggested

        if !s.events?
          data.status = "waiting" if data.status == "holding"
          evts.push @newEvent "suggested #{s.expert.username}"

          s.matchedBy = { userId: @usr._id, initials: Roles.getAdminInitials @usr.googleId }
          s.expertStatus = "waiting"
          s.events = [ @newEvent "first contacted" ]

      # log removing a suggestion
      if r.suggested?
        for s in r.suggested
          if !_.find(data.suggested, (sug) -> _.idsEqual sug._id, s._id)?
            evts.push @newEvent "removed suggested #{s.expert.username}"

      if evts.length is 0
        evts.push @newEvent "updated"

      data.events.push.apply data.events, evts

      @update id, data, cb


  """ Always return suggested rates and keep orders in sync """
  update: (id, data, cb) =>
    super id, data, (e, r) =>
      if !e?
        @rates.addRequestSuggestedRates r, true

        @mTagsSvc.copyToOrders id, r.marketingTags, r.owner, ->

      cb e, r


  addSelfSuggestion: (id, expertReview, cb) =>
    @getById id, (e, request) =>
      {status,suggested,events} = request
      eR = expertReview
      eR.expert.paymentMethod = type: 'paypal', info: { email: eR.payPalEmail }
      eR.expert = expertPick eR.expert
      suggested.push eR
      eR.events = [ @newEvent "self suggested" ]
      events.push @newEvent "self suggested #{eR.expert.username}"
      status = 'review' if status == 'holding' || status == 'waiting'
      @update id, {suggested,events,status}, (ee, r) =>
        if !e
          @mailman.importantRequestEvent "expert self suggested", @usr, r
        cb ee, Data.select(r, 'associated')


  updateSuggestionByExpert: (request, expertReview, cb) =>
    # $log 'updateSuggestionByExpert', request._id, expertReview._id
    # TODO, add some validation!!
    # if expertReview.agree
    # @settingsSvc.addPayPalSettings usr._id, expertReview.payPalEmail, (e, r) =>
      # if e then $log 'save.settings error:', e, r

    # $log 'expertReview', expertReview?, @usr._id
    eR = expertReview
    data = { suggested: request.suggested, events: request.events }
    data.events.push @newEvent "expert reviewed", eR
    sug = _.find request.suggested, (s) => _.idsEqual s.expert.userId, @usr._id
    sug.events.push @newEvent "expert updated"
    sug.expertRating = eR.expertRating
    sug.expertFeedback = eR.expertFeedback
    sug.expertComment = eR.expertComment
    sug.expertStatus = eR.expertStatus
    sug.expertAvailability = eR.expertAvailability
    sug.expert.paymentMethod = type: 'paypal', info: { email: eR.payPalEmail }

    if request.status == 'pending'
      if sug.expertStatus == 'available' then data.status = 'pending'
      if sug.expertStatus == 'abstained'
        data.canceledDetail = eR.expertComment + eR.expertFeedback
        data.status = 'canceled'
    # Thinking here is we still want to use the request with another experts so
    # maybe setting to 'canceled' is not the right thing to do ...

    @update request._id, data, (e, r) =>
      if !e
        @mailman.importantRequestEvent "expert reviewed #{eR.expertStatus}", @usr, r
      cb e, r

  listAllAvailableExpertsByTags: (cb) =>
    @searchMany { suggested: { $elemMatch: {expertStatus: 'available'} } }, {fields: {suggested: 1, tags: 1}}, (err, allRequests) =>
      if(!err)
        projection = _.map allRequests, (request) ->
          tags: _.map request.tags, (t) -> t.soId
          experts: _.compact _.map request.suggested, (sugg) ->
            if sugg.expertStatus is 'available'
              name: sugg.expert.name
              email: sugg.expert.email

        results = []
        _.each projection, (request) ->
          _.each _.sortBy(request.tags, (t) -> t), (tag) ->
            _.each request.experts, (expert) ->
              results.push([tag, expert.name, expert.email].join())

      cb err, _.uniq(_.sortBy(results, (r) -> r)).join("\n")

  requestEventsReport: (cb) =>
    @getAll (err, allRequests) =>
      results = [["utc","requestId","budget","hours","pricing","status","numberOfCalls","numberOfTags","numberOfSuggestions","tags","event"].join("\t")]
      if(!err)
        _.each allRequests, (request) ->
          _.each request.events, (event) ->
            a = [ event.utc,
              request._id,
              request.budget,
              request.hours,
              request.pricing,
              request.status,
              request.calls.length,
              request.tags.length,
              request.suggested.length,
              _.map(request.tags, 'soId').join(','),
              event.name ]

            results.push a.join("\t")

      cb(err, results.join("\n"))
