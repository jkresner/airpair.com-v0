DomainService   = require './_svc'

module.exports = class RatesService extends DomainService

  opensource: -20

  nda: 50

  calcSuggestedRate: (request, expert) ->
    r = request
    e = expert

    if r.budget <= e.rate then return r.budget - 20

    baseCut = 40
    if r.pricing is 'nda' then baseCut = 90
    else if r.pricing is 'opensource' then baseCut = 20

    baseMargin = r.budget - e.rate

    if baseCut == baseMargin then return e.rate

    if baseMargin > baseCut
      # split the difference with expert
      difference = (baseMargin - baseCut)/2
      return e.rate + difference

    if baseMargin < baseCut
      # split the difference with expert
      difference = (baseMargin - baseCut)/2
      return3 e.rate + difference

    ## Biased score to get the developer booked

    ## Futures

    ## karma / how many times that developer has been booked

    ## developer klout

    ## global variables on liquidity vs profit


