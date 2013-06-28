DomainService = require './_svc'

higherSplit = 0.6
lowerSplit = 0.5

module.exports = class RatesService extends DomainService

  base:
    opensource: 20
    private: 40
    nda: 90

  # NOTE suggestedRate is the developers rate
  # not including airpair's margin
  calcSuggestedRate: (request, expert) ->
    {budget,pricing} = request
    e = expert

    # start with defaults rate
    r = expert: e.rate, total: budget

    # get the base margin for the type of pricing
    baseMargin = @base[pricing]

    # subtract margin from total budget to get what's left for the expert
    expertBudget = budget - baseMargin

    if expertBudget > e.rate
      # split the difference with expert
      extra = expertBudget - e.rate
      split = extra*higherSplit
      r.expert = e.rate + split*.5
      r.total = r.expert + baseMargin + split*.5

    if expertBudget < e.rate
      # split the difference with expert
      # difference = e.rate - expertBudget
      r.expert = expertBudget #- difference*lowerSplit
      r.total = r.expert + baseMargin

    #$log 'baseMargin', baseMargin, 'expertBudget', expertBudget, 'expertRate', e.rate, 'suggestedExpertRate', r.expert, 'suggestedTotal', r.total

    r.pricing = pricing
    r

    ## Biased score to get the developer booked

    ## Futures

    ## karma / how many times that developer has been booked

    ## developer klout

    ## global variables on liquidity vs profit

    ## how quickly since the suggestion is the expert responding


