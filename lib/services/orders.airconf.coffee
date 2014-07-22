
# Logic associated with hacking AirConf purchases into the orders collection
# Advantage is it shows up in our dashboard and revenue reporting stays consistent across the company
# Note: this logic is extended into the OrdersService in it's constructor

"""
  Some funky hack rules about how AirConf orders work
  # 1) the status of "paid" means the users has claimed their pairing credit which exists in the firs lineItem
  # 2) Users register for talks using the other lineItems
  # 3) The total of other non-airconf purchases drives a discount for conference attendance
"""
module.exports =

  getAirConfRegisration: (cb) ->
    @searchMany {userId: @usr._id}, { fields: @Data.view.history }, (e, r) =>
      if e? then cb e, r

      d = paid: false, totalOtherPurchaes: 0, workshops: []

      confOrder = _.find r, (o) => _.idsEqual o.requestId, @Data.airconf.requestId

      paid = confOrder?
      d.totalOtherPurchaes += o.total for o in _.without(r, confOrder)

      if confOrder?
        d.confCredit = @Data.airconf.pairCredit if confOrder.status != 'paidout'
        for li in confOrder.lineItems
          d.workshops.push li if li.type == 'opensource'
      else
        d.discount = d.totalOtherPurchaes/10 % 10;

      $log 'getAirConf2014Order', cb, confOrder, d
      cb e, d
