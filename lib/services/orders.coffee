async             = require 'async'
mongoose          = require 'mongoose'
mailman           = require '../mail/mailman'
Roles             = require '../identity/roles'
DomainService     = require './_svc'
RequestService    = require './requests'
SettingsSvc       = require './settings'
RatesSvc          = require './rates'
calendar          = require './calendar'
StripeSvc         = require './wrappers/stripe'
PaypalAdaptiveSvc = require './wrappers/paypal-adaptive'
sum               = require '../mix/sum'
canSchedule       = require '../mix/canSchedule'
unschedule        = require '../mix/unschedule'
calcExpertCredit  = require '../mix/calcExpertCredit'
calcRedeemed      = calcExpertCredit.calcRedeemed
Data              = require './orders.query'
AirConfOrders     = require './orders.airconf'
Mixpanel          = require './mixpanel'

module.exports = class OrdersService extends DomainService

  model: require './../models/order'
  paypalSvc: new PaypalAdaptiveSvc()
  stripeSvc: new StripeSvc()
  rates: new RatesSvc()

  Chimp: require("../mail/chimp")
  AirConfDiscounts: require("./airConfDiscounts")

  constructor: (user) ->
    @Data = Data
    @requestSvc = new RequestService user
    @settingsSvc = new SettingsSvc user
    super user

  _calculateProfitAndPayouts: (order) ->
    airpairMargin = order.total

    for item in order.lineItems
      expertsHrRate = item.suggestion.suggestedRate[item.type].expert
      # item.expertsTotal is not persisted to the orderItem
      item.expertsTotal = item.qty * expertsHrRate
      airpairMargin -= item.expertsTotal

    order.profit = airpairMargin
    order

  createAnonCharge: (charge, callback) ->
    @stripeSvc.createAnonCharge charge, callback


  create: (order, callback) ->
    order._id = new mongoose.Types.ObjectId;
    order.userId = @usr._id

    payWith = 'paypal'
    if order.paymentMethod? && order.paymentMethod.type == 'stripe' then payWith = 'stripe'

    # $log 'create.payWith', payWith
    # ? if order.email != usr.primaryEmail
    # update user's primary email

    # 3rd party invoice integration ?
    order.invoice = {}
    @_calculateProfitAndPayouts order
    # $log 'create._calculateProfitAndPayouts.payWith', payWith
    savePaymentResponse = (e, paymentResponse) =>
      # $log 'savePaymentResponse.e', e
      if e then return callback e
      order.payment = paymentResponse

      if payWith is 'stripe' && paymentResponse? && !paymentResponse.failure_code?
        order.paymentStatus = 'received'
        order.paymentStatus = 'promo' if paymentResponse.type == '$0 order'
        @trackPayment order, 'stripe'

      new @model(order).save (e, rr) ->
        # $log 'order.save.e', e, rr, callback
        if e?
          # $log "order.save.error", e
          winston.error "order.save.error", e
        callback e, rr

    if order.total == 0 && order.paymentMethod.type == 'stripe'
      order.paymentType = 'stripe'
      savePaymentResponse null, { type: '$0 order' }
    else if order.paymentMethod? && order.paymentMethod.type == 'stripe'
      @stripeSvc.createCharge order, savePaymentResponse
    else
      @paypalSvc.Pay order, savePaymentResponse

  getByExpert: (expertId, callback) ->
    query = lineItems:
      $elemMatch:
        'suggestion.expert._id': expertId
    @searchMany query, @historySelect, (error, orders) ->
      callback error, orders

  getCredit: (userId, callback) =>
    userId ?= @usr._id
    @searchMany {userId: userId}, {}, (err, orders) =>
      credits = _.reduce orders, (orderCredits, order) =>
        orderCredits[order.requestId] ?= 0
        orderCredits[order.requestId] += @_orderCredit(order)
        orderCredits
      , {}
      callback err, {credits}

  getForHistory: (id, cb) =>
    userId = if id? && Roles.isAdmin(@usr) then id else @usr._id
    @searchMany {userId}, { fields: @Data.view.history }, cb

  confirmBookme: (request, expertReview, callback) ->
    @settingsSvc.getByUserId request.userId, (ee, settings) =>
      if ee then return callback ee
      pm = _.find settings.paymentMethods, (p) -> p.type == 'stripe'
      @requestSvc.updateSuggestionByExpert request, expertReview, (e, r) =>
        # $log 'request updated', r.status, r.suggested
        if e then return callback e
        if expertReview.expertStatus != 'available' then return callback e,r

        @_creditAvailable r, (err, creditAvailable) =>
          @_useCredit r, creditAvailable, (err, orders) =>
            order = { requestId: request._id, paymentMethod: pm, lineItems: [] }
            total = request.hours * request.budget
            order.total = total + creditAvailable
            order.company =
              _id: request.company._id
              name: request.company.name
              contacts: request.company.contacts

            toPick = ['_id','userId','name','username','rate','email','pic','paymentMethod']
            order.lineItems.push
              type: request.pricing
              total: order.total
              unitPrice: request.budget
              qty: parseInt request.hours
              suggestion:
                _id: request.suggested[0]._id
                suggestedRate: r.suggested[0].suggestedRate
                expert: _.pick request.suggested[0].expert, toPick
            @create order, (eeee,rrrr) -> callback(eeee,r)

  trackPayment: (order, type) ->
    props =
      usr: @usr.google._json.email
      distinct_id: @usr.google._json.email
      total: order.total
      profit: order.profit
      revenue: order.total
      type: type

    if order.utm?
      props.utm_source   = order.utm.utm_source
      props.utm_medium   = order.utm.utm_medium
      props.utm_term     = order.utm.utm_term
      props.utm_content  = order.utm.utm_content
      props.utm_campaign = order.utm.utm_campaign

    trackCallback = (error, response) =>
      if response? && _.some(response.results)
        mixpanelId = response.results[0]['$distinct_id']
        segmentio.track
          userId: mixpanelId
          event: 'customerPayment'
          properties: props

        # add event to request's log
        # TODO: when mongo can't find an ID, it returns null as the result.
        @requestSvc.getById order.requestId, (e, request) =>
          if e
            return winston.error 'trackPayment.@requestSvc.getById.error ' + e.stack
          request.events.push @newEvent('customer paid')

          mailman.importantRequestEvent "customer paid  #{order.total}", @usr, request

          @requestSvc.update request.id, { events: request.events }, (e) =>
            if e
              return winston.error 'trackPayment.@requestSvc.update.error ' + e.stack

    Mixpanel.user(@usr.google._json.email, trackCallback)


  markPaymentReceived: (id, paymentDetail, callback) ->
    @getById id, (e, r) =>
      if e then return callback e

      if Roles.isOrderOwner(@usr, r) || Roles.isAdmin(@usr)
        @paypalSvc.PaymentDetails r, (e, resp) =>
          if e then return callback e
          # INCOMPLETE = customer has paid but chained payment not executed
          # CREATED = customer has NOT yet paid
          if resp.status == 'INCOMPLETE'
            ups = paymentStatus: 'received'
            @trackPayment r, 'paypal'

            @update id, ups, callback
          else
            callback null, { e: 'update failed, not in INCOMPLETE state', data: resp }
      else
        callback null, { e: 'update failed, does not belong to user' }


  payOut: (id, payoutOptions, cb) ->
    if payoutOptions.type is 'paypalAdaptive'
      @payOutPayPalAdaptive id, cb
    else if payoutOptions.type is 'paypalSingle'
      @payOutPayPalSingle id, payoutOptions.lineItemId, cb
    else
      callback new Error "Payout[#{payoutOptions.type}] not implemented"


  _successfulPayoutIds: (payouts) ->
    payouts.filter (p) ->
      p.status == 'success'
    .map (p) ->
      p.lineItemId

  # allows flexibility to pay each expert individually via paypal
  payOutPayPalSingle: (id, lineItemId, callback) ->
    @model.findOne { _id: id }, (e, order) =>
      if e then return callback e
      if !order? || order.paymentStatus != "received"
        message = "not appropriate to execute payment #{id}"
        return callback status: 'failed', message: message

      lineItem = (order.lineItems.filter (l) -> l.id == lineItemId)[0]
      if !lineItem then return callback new Error 'No such lineItem id'

      successfulPayoutIds = @_successfulPayoutIds(order.payouts)
      if _.contains successfulPayoutIds, lineItemId
        message = "cannot pay out the same lineItem twice #{id}"
        return callback status: 'failed', message: message

      order = @_calculateProfitAndPayouts order
      @paypalSvc.PaySingle order, lineItem, (e, req, res) =>
        if e then return callback e
        # $log 'payOutPayPalSingle res', JSON.stringify(res)
        if res.responseEnvelope.ack != 'Success'
          message = "failed executing single payment #{id}"
          return callback status: 'failed', message: message, data: res

        order.payouts.push { type: 'paypal', status: 'success', lineItemId, req, res }
        ups = { payouts: order.payouts }

        if @_successfulPayoutIds(order.payouts).length == order.lineItems.length
          ups.paymentStatus = 'paidout'

        @update id, ups, callback

  # when you pay out an adaptive payment, it pays all experts at the same time
  payOutPayPalAdaptive: (id, callback) ->
    @model.findOne { _id: id }, (e, r) =>
      if e then return callback e
      if !r? || r.paymentStatus != "received"
        return callback status: 'failed', message: "not appropriate to execute payment #{id}"

      @paypalSvc.ExecutePayment r, (e, resp) =>
        if e then return callback e
        # $log 'resp', resp
        if resp.responseEnvelope.ack != 'Success'
          return callback status: 'failed', message: "failed executing payment #{id}", data: resp

        ups = paymentStatus: 'paidout', payment: r.payment
        ups.payment.payout = resp
        @update id, ups, callback

  #
  swapExpert: (id, suggestion, callback) ->
    @model.findOne { _id: id }, (e, r) =>
      if e then return callback e
      if !r?
        callback status: 'failed', message: "order does not exist"
      else if r.paymentStatus == "paidout"
        callback status: 'failed', message: "not appropriate to swap a paidout order"
      else if r.lineItems.length != 1
        callback status: 'failed', message: "can only swap on order with one expert"
      else
        r.lineItems[0].suggestion._id = suggestion._id
        r.lineItems[0].suggestion.expert = _.pick suggestion.expert, '_id','userId','name','username','rate','email','pic','paymentMethod'

        callIds = _.pluck r.lineItems[0].redeemedCalls, 'callId'

        @requestSvc.getById r.requestId, (e, request) =>
          request.events.push @newEvent('swaped order expert')

          updateCallAndInvite = (callId, cb) =>
            call = _.find request.calls, (c) -> _.idsEqual c._id, callId
            call.expertId = suggestion.expert._id
            calendar.changeExpert request, call, suggestion.expert, (err, eventData) =>
              if err then return callback err
              call.gcal = eventData
              cb()

          async.map callIds, updateCallAndInvite, =>
            @requestSvc.update request.id, { events: request.events, calls: request.calls }, (e) =>
              @update id, { lineItems: r.lineItems }, callback




  delete: (id, callback) =>
    @model.findOne { _id: id }, (e, r) =>
      if e then return callback e
      if !r? || r.paymentStatus != "pending"
        return callback status: "failed to delete order #{id}"
      @model.find( _id: id ).remove (ee, rr) =>
        if ee then return callback ee
        callback null, status: 'deleted'

  # oldest orders first (smallest timestamp -> biggest timestamp)
  getByRequestId: (requestId, cb) =>
    @searchMany {requestId}, {options: $sort: { utc: 1 }}, cb

  ###

  # call related code

  Scheduling a call means going through the orders, determining if there's
  enough hour-credit, and then modifying the orders with the length of the new
  call.

  Here is an order's lineItem before scheduling. I've left out
  irrelevant properties:

    lineItem = {
      # total number of hours the customer bought
      qty: 3
      redeemedCalls: []
      type: 'opensource'
      suggestion: { expert: { _id: expertId } }
    }

  After scheduling a 1-hour call with `expertId` that is opensource

    lineItem = {
      # total number of hours the customer bought
      qty: 3
      redeemedCalls: [
        callId: callId
        qtyRedeemed: 1 # the length of the call
        qtyCompleted: 0
      ]
      type: 'opensource'
      suggestion: { expert: { _id: expertId } }
    }

  The callId allows us to remove the call later, if we needed to unschedule
  and then re-schedule the call with a different duration. Editing a call's
  duration is accomplished by basically deleting the call from all the
  lineItems, and then scheduling it again against the same lineItems. LineItems
  are sorted by age, and because it edits the oldest ones first, the same
  lineItems are be affected.

  When a call is marked as completed, we locate all the matching redeemedCalls,
  and change qtyCompleted to match the length of the call (qtyRedeemed).
  ###

  schedule: (requestId, call, cb) =>
    @getByRequestId requestId, (err, orders) =>
      if err then return cb err
      if !canSchedule orders, call
        message = 'Not enough hours to schedule this call; please order more'
        return cb new Error message

      modifiedOrders = @_modifyWithDuration orders, call
      @_saveLineItems modifiedOrders, cb

  # removes redeemed calls matching the call's ID from the orders, then tries to
  # schedule it again with this calls duration (the duration is different)
  updateWithCall: (requestId, call, cb) =>
    @getByRequestId requestId, (err, orders) =>
      if err then return cb err
      ordersWithoutCall = unschedule orders, call._id

      if !canSchedule ordersWithoutCall, call
        message = "Not enough hours to edit call's duration; please order more"
        return cb new Error message

      modifiedOrders = @_modifyWithDuration ordersWithoutCall, call
      modifiedOrders = @_markComplete modifiedOrders, call
      @_saveLineItems modifiedOrders, cb

  # when a recording has been added to a call and nothing else has changed,
  # this is used to complete the relevant hours on the orders
  updateCompletion: (requestId, call, cb) =>
    @getByRequestId requestId, (err, orders) =>
      if err then return cb err

      modifiedOrders = @_markComplete orders, call
      @_saveLineItems modifiedOrders, cb

  # calculates the credit available for the request
  # uses the allowed creditRequestIds on the expert
  # and finds user orders with credit that match
  # returns 0 or a negative number
  _creditAvailable: (request, callback) ->
    @getCredit request.userId, (err, customerCredits) =>
      expert = request.suggested[0].expert
      expertCreditIds = expert.bookMe.creditRequestIds || []
      total = request.hours * request.budget
      credit = _.reduce expertCreditIds, (sum, id) =>
        sum += (customerCredits.credits[id] || 0)
      , 0
      creditAvailable = if credit + total >= 0 then credit else -total
      callback(err, creditAvailable)

  _useCredit: (request, totalCredit, callback) ->
    return callback(null, []) if totalCredit == 0
    creditToApply = Math.abs(totalCredit)
    suggestion = request.suggested[0]
    expertCreditIds = suggestion.expert.bookMe.creditRequestIds || []
    @searchMany {userId: request.userId}, {}, (err, orders) =>
      creditOrders = _.select orders, (order) =>
        order.requestId.toString() in expertCreditIds && @_orderCredit(order) < 0
      creditOrders = _.map creditOrders, (order) =>
        if creditToApply > 0
          orderCredit = @_orderCredit(order)
          lineItemCredit = 0
          if orderCredit + creditToApply >= 0
            lineItemCredit = Math.abs(orderCredit)
            creditToApply += orderCredit
          else
            lineItemCredit = Math.abs(creditToApply)
            creditToApply = 0
          toPick = ['_id','userId','name','username','rate','email','pic','paymentMethod']
          if lineItemCredit + orderCredit == 0
            order.paymentStatus = "paidout"
          order.lineItems.push
            type: 'credit'
            total: lineItemCredit
            unitPrice: lineItemCredit
            qty: 1
            suggestion:
              _id: suggestion._id
              suggestedRate: suggestion.suggestedRate
              expert: _.pick suggestion.expert, toPick
        order
      saveOrder = (order, cb) =>
        update = $set: { paymentStatus: order.paymentStatus, lineItems: order.lineItems }
        @model.findByIdAndUpdate order._id, update, cb
      async.map orders, saveOrder, callback

  _orderCredit: (order) ->
    return 0 if order.paymentStatus == "paidout"
    _.reduce order.lineItems, (orderCredit, lineItem) =>
      if lineItem.type == "credit"
        orderCredit += lineItem.qty * lineItem.unitPrice
      orderCredit
    , 0

  # adds the appropriate redeemedCall object to orders that match the call's
  # criteria (same type, same expert).
  # the math.min stuff allows a 3 hour call to be spread across more than one
  # lineItem (the customer made more than one order).
  _modifyWithDuration: (orders, call) =>
    toAllocate = call.duration
    modified = []
    for order in orders
      if toAllocate == 0 then break
      order.lineItems.filter (lineItem) =>
        sameType = lineItem.type == call.type
        sameExpert = _.idsEqual lineItem.suggestion.expert._id, call.expertId
        sameType && sameExpert
      .forEach (lineItem) =>
        if toAllocate == 0 then return
        qtyRemaining = lineItem.qty - calcRedeemed([lineItem])
        if qtyRemaining == 0 then return # this lineItem is already full
        redeemedCall = { callId: call._id, qtyRedeemed: 0, qtyCompleted: 0 }
        lineItem.redeemedCalls = lineItem.redeemedCalls || []
        allocated = Math.min toAllocate, qtyRemaining
        toAllocate -= allocated
        redeemedCall.qtyRedeemed += allocated
        lineItem.redeemedCalls.push redeemedCall
        # this doesnt push duplicate orders b/c there is only one lineitem for
        # each expert in an order
        modified.push order
    modified

  # if call has a recording, marks the call's matching redeemedCalls as complete
  _markComplete: (orders, call) =>
    if !call.recordings.length then return orders
    for order in orders
      for li in order.lineItems
        for rc in li.redeemedCalls
          if !_.idsEqual(rc.callId, call._id) then continue
          # the length of the video doesn't matter; any video marks it completed
          rc.qtyCompleted = rc.qtyRedeemed
    orders

  # TODO batch update?
  _saveLineItems: (orders, callback) =>
    saveOrder = (order, cb) =>
      update = $set: { lineItems: order.lineItems }
      @model.findByIdAndUpdate order._id, update, cb
    async.map orders, saveOrder, callback


  """ Don't want to fill OrdersService files with obscure AirConf logic, this was best I could think of """
  getAirConfRegistration: => AirConfOrders.getAirConfRegistration.apply @, arguments
  getAirConfPromoRate: => AirConfOrders.getAirConfPromoRate.apply @, arguments
  createAirConfOrder: => AirConfOrders.createAirConfOrder.apply @, arguments


