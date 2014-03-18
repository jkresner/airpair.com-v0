async    = require 'async'
mongoose = require 'mongoose'

mailman          = require '../mail/mailman'
Roles            = require '../identity/roles'
sum              = require '../../app/scripts/shared/mix/sum'
canSchedule      = require '../../app/scripts/shared/mix/canSchedule'
unschedule       = require '../../app/scripts/shared/mix/unschedule'
calcExpertCredit = require '../../app/scripts/shared/mix/calcExpertCredit'
calcRedeemed     = calcExpertCredit.calcRedeemed

DomainService     = require './_svc'
PaypalAdaptiveSvc = require '../services/payment/paypal-adaptive'
RequestService    = require './requests'
StripeSvc         = require '../services/payment/stripe'
SettingsSvc       = require './settings'
RatesSvc         = require './rates'


module.exports = class OrdersService extends DomainService

  model: require './../models/order'
  paypalSvc: new PaypalAdaptiveSvc()
  stripSvc: new StripeSvc()
  requestSvc: new RequestService()
  settingsSvc: new SettingsSvc()
  rates: new RatesSvc()

  _calculateProfitAndPayouts: (order) ->
    airpairMargin = order.total

    for item in order.lineItems
      expertsHrRate = item.suggestion.suggestedRate[item.type].expert
      # item.expertsTotal is not persisted to the orderItem
      item.expertsTotal = item.qty * expertsHrRate
      airpairMargin -= item.expertsTotal

    order.profit = airpairMargin
    order

  create: (order, usr, callback) ->
    order._id = new mongoose.Types.ObjectId;
    order.userId = usr._id

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
      $log 'savePaymentResponse.e', e
      if e then return callback e
      order.payment = paymentResponse

      if payWith is 'stripe' && paymentResponse? && !paymentResponse.failure_code?
        order.paymentStatus = 'received'
        @trackPayment usr, order, 'stripe'

      new @model(order).save (e, rr) ->
        $log 'order.save.e', e, callback
        if e?
          $log "order.save.error", e
          winston.error "order.save.error", e
        callback e, rr

    if order.paymentMethod? && order.paymentMethod.type == 'stripe'
      $log 'stripSvc.createCharge', order
      @stripSvc.createCharge order, savePaymentResponse
    else
      @paypalSvc.Pay order, savePaymentResponse


  confirmBookme: (request, usr, expertReview, callback) ->
    @settingsSvc.getByUserId request.userId, (ee, settings) =>
      if ee then return callback ee
      pm = _.find settings.paymentMethods, (p) -> p.type == 'stripe'
      # $log 'pm', pm

      @requestSvc.updateSuggestionByExpert request, usr, expertReview, (e, r) =>
        $log 'request updated', r.status, r.suggested
        if e then return callback e
        order = { requestId: request._id, paymentMethod: pm, lineItems: [] }
        order.total = request.hours * request.budget
        order.company =
          _id: request.company._id
          name: request.company.name
          contacts: request.company.contacts

        expertBookMe = { rake: 10 }

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

        @create order, usr, (eeee,rrrr) -> callback(eeee,r)


  trackPayment: (usr, order, type) ->
    props = {
      usr: usr.google._json.email, distinct_id: usr.google._json.email,
      total: order.total, profit: order.profit, type: type
    }

    if order.utm?
      props.utm_source   = order.utm.utm_source
      props.utm_medium   = order.utm.utm_medium
      props.utm_term     = order.utm.utm_term
      props.utm_content  = order.utm.utm_content
      props.utm_campaign = order.utm.utm_campaign

    mixpanel.track 'customerPayment', props
    mixpanel.people.track_charge usr.google._json.email, order.total

    # add event to request's log
    # TODO: when mongo can't find an ID, it returns null as the result.
    @requestSvc.getById order.requestId, (e, request) =>
      if e
        return winston.error 'trackPayment.@requestSvc.getById.error' + e.stack
      request.events.push @newEvent(usr, 'customer paid')

      mailman.importantRequestEvent "customer paid  #{order.total}", usr, request

      @requestSvc.update request.id, { events: request.events }, (e) =>
        if e
          return winston.error 'trackPayment.@requestSvc.update.error' + e.stack

  markPaymentReceived: (id, usr, paymentDetail, callback) ->
    @model.findOne { _id: id }, (e, r) =>
      if e then return callback e

      if Roles.isOrderOwner(usr, r) || Roles.isAdmin(usr)
        @paypalSvc.PaymentDetails r, (e, resp) =>
          if e then return callback e
          # INCOMPLETE = customer has paid but chained payment not executed
          # CREATED = customer has NOT yet paid
          if resp.status == 'INCOMPLETE'
            ups = paymentStatus: 'received'
            @trackPayment usr, r, 'paypal'

            @update id, ups, callback
          else
            callback null, { e: 'update failed, not in INCOMPLETE state', data: resp }
      else
        callback null, { e: 'update failed, does not belong to user' }

  payOut: (id, payoutOptions, order, callback) ->
    if payoutOptions.type is 'paypalAdaptive'
      return @payOutPayPalAdaptive id, callback
    if payoutOptions.type is 'paypalSingle'
      return @payOutPayPalSingle id, payoutOptions.lineItemId, callback
    return callback new Error "Payout[#{payoutOptions.type}] not implemented"

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
        $log 'payOutPayPalSingle res', JSON.stringify(res)
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

  delete: (id, callback) =>
    @model.findOne { _id: id }, (e, r) =>
      if e then return callback e
      if !r? || r.paymentStatus != "pending"
        return callback status: "failed to delete order #{id}"
      @model.find( _id: id ).remove (ee, rr) =>
        if ee then return callback ee
        callback null, status: 'deleted'

  # oldest orders first (smallest timestamp -> biggest timestamp)
  getByRequestId: (requestId, callback) =>
    query = requestId: requestId
    sort = utc: 'asc'
    @search(query).sort(sort).exec callback

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
      update = $set: { lineItems: order.toJSON().lineItems }
      @model.findByIdAndUpdate order._id, update, cb
    async.map orders, saveOrder, callback
