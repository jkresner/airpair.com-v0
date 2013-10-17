DomainService   = require './_svc'
Roles           = require './../identity/roles'
PaypalAdaptiveSvc = require './../services/payment/paypal-adaptive'
StripeSvc = require './../services/payment/stripe'
mongoose = require 'mongoose'

module.exports = class OrdersService extends DomainService

  model: require './../models/order'
  paypalSvc: new PaypalAdaptiveSvc()
  stripSvc: new StripeSvc()  

  create: (order, user, callback) ->
    order._id = new mongoose.Types.ObjectId;
    order.userId = user._id

    # ? if order.email != user.primaryEmail
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

    savePaymentResponse = (paymentResponse) => 
      order.payment = paymentResponse
      $log "order.payment", order if cfg.isProd
      winston.log "order.payment", order
      new @model(order).save (e, rr) ->
        if e?
          $log "order.save.error", e, o.payment
          winston.errror "order.save.error", e
        callback rr

    if order.payWith? && order.payWith.type is 'stripe'
      stripSvc.createCharge order, savePaymentResponse
    else
      @paypalSvc.Pay order, savePaymentResponse
        

  markPaymentReceived: (id, usr, paymentDetail, callback) ->
    @model.findOne { _id: id }, (e, r) =>
      if Roles.isOrderOwner(usr, r) || Roles.isAdmin(usr)
        @paypalSvc.PaymentDetails r, (resp) =>
          # INCOMPLETE = customer has paid but chained payment not executed
          # CREATED = customer has NOT yet paid
          if resp.status == 'INCOMPLETE'
            ups = paymentStatus: 'received'
  
            mixpanel.track 'customerPayment', { distinct_id: usr.google._json.email, total: r.total }
            mixpanel.people.track_charge usr.google._json.email, r.total
            
            @update id, ups, callback
          else
            callback { e: 'update failed, not in INCOMPLETE state', data: resp }
      else
        callback { e: 'update failed, does not belong to user' }


  payOutToExperts: (id, callback) ->
    @model.findOne { _id: id }, (e, r) =>
      if !r? || r.paymentStatus != "received"
        return callback status: 'failed', message: "not appropriate to execute payment #{id}"

      @paypalSvc.ExecutePayment r, (resp) =>
        # $log 'resp', resp
        if resp.responseEnvelope.ack != 'Success'
          return callback status: 'failed', message: "failed executing payment #{id}", data: resp

        ups = paymentStatus: 'paidout', payment: r.payment
        ups.payment.payout = resp
        @update id, ups, callback


  delete: (id, callback) =>
    @model.findOne { _id: id }, (e, r) =>
      if !r? || r.paymentStatus != "pending"
        return callback status: "failed to delete order #{id}"
      @model.find( _id: id ).remove (ee, rr) =>
        callback status: 'deleted'