# Logic associated with hacking AirConf purchases into the orders collection
# Advantage is it shows up in our dashboard and revenue reporting stays consistent across the company
# Note: this logic is extended into the OrdersService in it's constructor

"""
  Some funky hack rules about how AirConf orders work
  # 1) the status of "paidout" means the users has claimed their pairing credit which exists in the firsy lineItem
  # 2) The total of other non-airconf purchases drives a discount for conference attendance
  # 3) Credit is stored on a type: 'credit' lineItem as a negative number. As credit is used positive 'credit' lineItems are
  #    added to offset the value (at which point we will mark the order 'paidout'
"""
module.exports =

  # These are defined in Orders service
  # Chimp: require("../mail/chimp")
  # AirConfDiscounts: require("./airConfDiscounts")

  getAirConfRegisration: (cb) ->
    if !@usr? then return cb()
    @searchMany {userId: @usr._id}, { fields: @Data.view.history }, (e, r) =>
      if e? then cb(e, r)

      confOrder = _.find r, (order) =>
        _.idsEqual order.requestId, @Data.airconf.requestId

      { ticketPrice, pairCredit } = @Data.airconf

      d = { paid: confOrder?, workshops: [], confOrder, ticketPrice, pairCredit }

      d.totalOtherPurchaes += o.total for o in _.without(r, confOrder)

      if confOrder?
        d.confCredit = @Data.airconf.pairCredit if confOrder.paymentStatus != 'paidout'
        for li in confOrder.lineItems
          d.workshops.push li if li.type == 'opensource'
      else
        d.discount = d.totalOtherPurchaes/10 % 10

      # $log 'getConfOrder', d
      cb e, d

  createAirConfOrder: (order, cb) ->
    @AirConfDiscounts.lookup order.promocode, (e, code) =>
      unless e? then order.total = code.cost
      orderEmail = order.company.contacts[0].email
      order.company.contacts[0].pic = gravatarLnk orderEmail

      createOrder = (e, settings) =>
        order.paymentMethod = _.find(settings.paymentMethods, (p) -> p.type == 'stripe')
        order.requestId = @Data.airconf.requestId
        order.lineItems = [ @Data.airconf.ticketLineItem, @Data.airconf.pairCreditLineItem ]
        @create order, (e, order) =>
          @Chimp.subscribe config.mailchimp.airconfListId, orderEmail, { Paid: 'Yes' }
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
