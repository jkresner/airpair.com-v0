DomainService = require './_svc'

higherSplit = 0.6
lowerSplit = 0.5

module.exports = class RatesService extends DomainService

  base:
    opensource: 20
    private: 40
    nda: 90

  getRelativeBudget: (budget, requestPricing, pricing) ->
    return budget - (@base[requestPricing]-@base[pricing])

  # NOTE suggestedRate is the developers rate
  # not including airpair's margin
  calcSuggestedRates: (request, expert) ->
    e = expert

    r = {}
    for pricing in ['opensource','private','nda']

      # get the base margin for the type of pricing
      baseMargin = @base[pricing]

      # if the user was to change their choice between opensource / private
      relativeBudget = @getRelativeBudget request.budget, request.pricing, pricing

      # start with defaults rate
      pr = expert: e.rate, total: relativeBudget

      # subtract margin from total budget to get what's left for the expert
      expertBudget = relativeBudget - baseMargin

      if expertBudget > e.rate
        # split the difference with expert
        extra = expertBudget - e.rate
        split = extra*higherSplit
        pr.expert = e.rate + split*.5
        pr.total = pr.expert + baseMargin + split*.5

      if expertBudget < e.rate
        # split the difference with expert
        # difference = e.rate - expertBudget
        pr.expert = expertBudget #- difference*lowerSplit
        pr.total = pr.expert + baseMargin

      # we could do more complex things on the split between
      # the expert and airpair
      if pricing is 'nda'
        # give the expert $20 more p.h. for nda
        pr.expert += 20

      r[pricing] = pr
      # $log 'baseMargin', baseMargin, 'expertBudget', expertBudget, 'expertRate', e.rate, 'suggestedExpertRate', pr.expert, 'suggestedTotal', pr.total

    r

    ## Biased score to get the developer booked

    ## Futures

    ## karma / how many times that developer has been booked

    ## developer klout

    ## global variables on liquidity vs profit

    ## how quickly since the suggestion is the expert responding


