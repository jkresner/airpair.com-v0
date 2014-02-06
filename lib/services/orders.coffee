async = require 'async'
mongoose = require 'mongoose'

expertCredit = require '../../app/scripts/shared/mix/expertCredit'
mailman = require '../mail/mailman'
Roles = require '../identity/roles'
sum = require '../../app/scripts/shared/mix/sum'

DomainService = require './_svc'
PaypalAdaptiveSvc = require '../services/payment/paypal-adaptive'
RequestService = require './requests'
StripeSvc = require '../services/payment/stripe'

module.exports = class OrdersService extends DomainService

  model: require './../models/order'
  paypalSvc: new PaypalAdaptiveSvc()
  stripSvc: new StripeSvc()
  requestSvc: new RequestService()

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

    # ? if order.email != usr.primaryEmail
    # update user's primary email

    # 3rd party invoice integration ?
    order.invoice = {}
    @_calculateProfitAndPayouts order

    savePaymentResponse = (e, paymentResponse) =>
      if e then return callback e
      order.payment = paymentResponse

      if payWith is 'stripe' && paymentResponse? && !paymentResponse.failure_code?
        order.paymentStatus = 'received'
        @trackPayment usr, order, 'stripe'

      new @model(order).save (e, rr) ->
        if e?
          $log "order.save.error", e
          winston.error "order.save.error", e
        callback e, rr

    if order.paymentMethod? && order.paymentMethod.type == 'stripe'
      @stripSvc.createCharge order, savePaymentResponse
    else
      @paypalSvc.Pay order, savePaymentResponse

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

  # also sorts by age; oldest first!
  getByRequestId: (requestId, callback) =>
    @search { requestId: requestId }, (err, orders) =>
      if err then return callback err
      callback null, orders.sort(@_byUtc)

  _byUtc: (order1, order2) ->
    order1.utc - order2.utc

  #
  # call related
  #

  _unschedule: (orders, callId) ->
    orders.map (o) ->
      o.lineItems = o.lineItems.map (li) ->
        li.redeemedCalls = _.reject li.redeemedCalls, (rc) ->
          _.idsEqual rc.callId, callId
        li
      o

  getByRequestIdWithoutCall: (requestId, callId, callback) =>
    @getByRequestId requestId, (e, orders) =>
      if e then return callback e
      callback null, @_unschedule orders, callId

  _canSchedule: (orders, call) =>
    credit = expertCredit orders, call.expertId
    byType = credit.byType[call.type]
    if !byType then return false
    call.duration <= byType.balance

  _qtyRemaining: (lineItem) ->
    lineItem.qty - sum _.pluck lineItem.redeemedCalls, 'qtyRedeemed'

  _modifyWithDuration: (orders, call) =>
    allocatedSoFar = 0
    done = false
    modified = []
    for order in orders
      if done then break
      order.lineItems.filter (lineItem) =>
        sameType = lineItem.type == call.type
        sameExpert = _.idsEqual lineItem.suggestion.expert._id, call.expertId
        sameType && sameExpert
      .map (lineItem) =>
        if done then return
        redeemedCall = { callId: call._id, qtyRedeemed: 0, qtyCompleted: 0 }
        lineItem.redeemedCalls = lineItem.redeemedCalls || []
        allocated = Math.min call.duration, @_qtyRemaining(lineItem)
        allocatedSoFar += allocated
        redeemedCall.qtyRedeemed += allocated

        lineItem.redeemedCalls.push redeemedCall
        modified.push order
        done = allocatedSoFar == call.duration
    modified

  # TODO batch update?
  _saveLineItems: (orders, callback) =>
    saveOrder = (order, cb) =>
      update = $set: { lineItems: order.toJSON().lineItems }
      @model.findByIdAndUpdate order._id, update, cb
    async.map orders, saveOrder, callback

  schedule: (requestId, call, cb) =>
    @getByRequestId requestId, (err, orders) =>
      if err then return cb err
      @_checkAndSchedule orders, call, cb

  # removes redeemed calls matching the call's ID from the orders, then tries to
  # schedule it again with this calls duration (the duration is different)
  updateDuration: (requestId, call, cb) =>
    @getByRequestId requestId, (err, orders) =>
      if err then return cb err
      ordersWithoutCall = @_unschedule orders, call._id
      @_checkAndSchedule ordersWithoutCall, call, cb

  _checkAndSchedule: (orders, call, cb) =>
    if !@_canSchedule orders, call
      message = 'Not enough hours to set up this call; please order more'
      return cb new Error message

    modifiedOrders = @_modifyWithDuration orders, call
    @_saveLineItems modifiedOrders, cb
