DomainService   = require './_svc'

module.exports = class RatesService extends DomainService

  opensource: -20

  nda: 50

  # NOTE suggestedRate is the developers rate
  # not including airpair's margin
  calcSuggestedRate: (request, expert) ->
    r = request
    e = expert

    if r.budget <= e.rate then return r.budget - 20

    baseMargin = 40
    if r.pricing is 'nda' then baseMargin = 90
    else if r.pricing is 'opensource' then baseMargin = 20

    margin = r.budget - e.rate

    if baseMargin == margin then return e.rate

    else if margin > baseMargin
      # split the difference with expert
      difference = margin - baseMargin
      return e.rate + difference*.5

    else # margin < baseMargin
      # split the difference with expert
      difference = baseMargin - margin
      return e.rate - difference*.5

    ## Biased score to get the developer booked

    ## Futures

    ## karma / how many times that developer has been booked

    ## developer klout

    ## global variables on liquidity vs profit

    ## how quickly since the suggestion is the expert responding


