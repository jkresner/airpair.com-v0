DomainService   = require './_svc'
Roles           = require './../identity/roles'
PaypalAdaptiveSvc = require './../services/payment/paypal-adaptive'
StripeSvc = require './../services/payment/stripe'
mongoose = require 'mongoose'

module.exports = class OrdersService extends DomainService

  model: require './../models/order'
  paypalSvc: new PaypalAdaptiveSvc()
  stripSvc: new StripeSvc()  

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

    savePaymentResponse = (paymentResponse) => 
      order.payment = paymentResponse

      if payWith is 'stripe' && paymentResponse? && !paymentResponse.failure_code? 
        order.paymentStatus = 'received'
        @trackPayment usr, order
        
      new @model(order).save (e, rr) ->
        if e?
          $log "order.save.error", e
          winston.error "order.save.error", e
        callback rr

    if order.paymentMethod? && order.paymentMethod.type == 'stripe'
      @stripSvc.createCharge order, savePaymentResponse
    else
      @paypalSvc.Pay order, savePaymentResponse
        
  trackPayment: (usr, order) ->
    r = order
    props = { distinct_id: usr.google._json.email, total: r.total, profit: r.profit }

    if r.utm?
      props.utm_source = r.utm.utm_source
      props.utm_medium = r.utm.utm_medium
      props.utm_term = r.utm.utm_term
      props.utm_content = r.utm.utm_content
      props.utm_campaign = r.utm.utm_campaign

    mixpanel.track 'customerPayment', props
    mixpanel.people.track_charge usr.google._json.email, r.total
               

  markPaymentReceived: (id, usr, paymentDetail, callback) ->
    @model.findOne { _id: id }, (e, r) =>
      if Roles.isOrderOwner(usr, r) || Roles.isAdmin(usr)
        @paypalSvc.PaymentDetails r, (resp) =>
          # INCOMPLETE = customer has paid but chained payment not executed
          # CREATED = customer has NOT yet paid
          if resp.status == 'INCOMPLETE'
            ups = paymentStatus: 'received'
            @trackPayment usr, r
    
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