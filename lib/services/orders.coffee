mongoose = require 'mongoose'
mailman = require '../mail/mailman'
Roles = require '../identity/roles'

DomainService = require './_svc'
PaypalAdaptiveSvc = require '../services/payment/paypal-adaptive'
RequestService = require './requests'
StripeSvc = require '../services/payment/stripe'

module.exports = class OrdersService extends DomainService

  model: require './../models/order'
  paypalSvc: new PaypalAdaptiveSvc()
  stripSvc: new StripeSvc()
  requestSvc: new RequestService()

  create: (order, usr, callback) ->
    order._id = new mongoose.Types.ObjectId;
    order.userId = usr._id

    payWith = 'paypal'
    if order.paymentMethod? && order.paymentMethod.type == 'stripe' then payWith = 'stripe'

    # ? if order.email != usr.primaryEmail
    # update user's primary email

    # 3rd party invoice integration ?
    order.invoice = {}
    airpairMargin = order.total

    for item in order.lineItems
      expertsHrRate = item.suggestion.suggestedRate[item.type].expert
      # item.expertsTotal is not persisted to the orderItem
      item.expertsTotal = item.qty * expertsHrRate
      airpairMargin -= item.expertsTotal

    order.profit = airpairMargin

    $log '#3 Order.profit', order

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
    @requestSvc.getById order.requestId, (e, request) =>
      if e
        return winston.error 'trackPayment.@requestSvc.getById.error' + e.stack
      request.events.push @newEvent(usr, 'customer paid')

      options = {
        user: usr.google && usr.google.displayName
        evtName: 'customer paid'
        owner: request.owner
        requestId: request._id
      }
      mailman.importantRequestEvent options

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


  payOutToExperts: (id, callback) ->
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
