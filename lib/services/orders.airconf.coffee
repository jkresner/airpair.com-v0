# Logic associated with hacking AirConf purchases into the orders collection
# Advantage is it shows up in our dashboard and revenue reporting stays consistent across the company
# Note: this logic is extended into the OrdersService in it's constructor

"""
  Some funky hack rules about how AirConf orders work
  # 1) the status of "paid" means the users has claimed their pairing credit which exists in the firs lineItem
  # 2) Users register for talks using the other lineItems
  # 3) The total of other non-airconf purchases drives a discount for conference attendance
"""
chimp = require "../mail/chimp"

module.exports =

  getAirConfRegisration: (cb) ->
    @searchMany {userId: @usr._id}, { fields: @Data.view.history }, (e, r) =>
      if e? then cb(e, r)

      confOrder = _.find r, (order) =>
        _.idsEqual order.requestId, @Data.airconf.requestId

      { ticketPrice, pairCredit } = @Data.airconf

      d = { paid: confOrder?, workshops: [], confOrder, ticketPrice, pairCredit }

      d.totalOtherPurchaes += o.total for o in _.without(r, confOrder)

      if confOrder?
        d.confCredit = @Data.airconf.pairCredit if confOrder.status != 'paidout'
        for li in confOrder.lineItems
          d.workshops.push li if li.type == 'opensource'
      else
        d.discount = d.totalOtherPurchaes/10 % 10;

      $log 'getConfOrder', d
      cb e, d

  createAirConfOrder: (order, cb) ->
    @getAirConfPromoRate order.promocode, (e,d) -> order.total = d.promoRate
    orderEmail = order.company.contacts[0].email
    order.company.contacts[0].pic = gravatarLnk orderEmail

    createOrder = (e, settings) =>
      order.paymentMethod = _.find settings.paymentMethods, (p) -> p.type == 'stripe'
      order.requestId = @Data.airconf.requestId
      order.lineItems = [ @Data.airconf.ticketLineItem, @Data.airconf.pairCreditLineItem ]
      @create order, (e, order) =>
        chimp.subscribe config.mailchimp.airconfListId, orderEmail, { Paid: 'Yes' }
        cb(e, order)

    if order.stripeCreate?
      @settingsSvc.getByUserId @usr._id, (e, s) =>
        s = _.extend s, { stripeCreate: order.stripeCreate }
        if !s.paymentMethods?
          s.paymentMethods = []
          s.userId = @usr._id
        @settingsSvc.createStripeSettings s, createOrder
    else
      @settingsSvc.getByUserId @usr._id, createOrder


  getAirConfPromoRate: (promoCode, cb) ->
    restler.get(config.defaults.airconf.discountCodesUrl)
      .on 'success', (data, response) ->
        entry = _.find(data.feed.entry, (e) -> e.gsx$code.$t == promoCode)
        if entry?
          paybutton = entry.gsx$paybutton?.$t || "Pay $#{entry.gsx$cost.$t} for my ticket"
          data =
            paybutton: paybutton
            cost: entry.gsx$cost.$t
            code: entry.gsx$code.$t
            message: "Discount applied."
          cb(null, data)
        else
          cb(status: 404, message: 'Unknown code.')
      .on 'error', (err, response) ->
        cb(err)

