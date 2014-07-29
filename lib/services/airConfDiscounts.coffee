class AirConfDiscounts

  beforeExpiration = (entry) ->
    expirationDate = new Date(entry.gsx$expires?.$t)
    new Date < expirationDate

  lookup: (promoCode, cb) ->
    restler.get(config.defaults.airconf.discountCodesUrl)
      .on 'success', (data, response) ->
        entry = _.find(data.feed.entry, (e) -> e.gsx$code.$t == promoCode)
        if entry?
          if not beforeExpiration(entry)
            return cb({message: "Code expired."}, {valid: false})

          data =
            paybutton: entry.gsx$paybutton?.$t || "Pay $#{entry.gsx$cost.$t} for my ticket"
            cost: parseInt(entry.gsx$cost.$t)
            code: entry.gsx$code.$t
            organization: entry.gsx$organization?.$t
            offer: entry.gsx$offer?.$t
            message: "Discount applied."
            valid: true

          console.log 'discount.data', data

          cb(null, data)

        else
          cb({message: 'Unknown code.'}, {valid: false})

      .on 'error', (err, response) ->
        cb(err)

module.exports = new AirConfDiscounts()
