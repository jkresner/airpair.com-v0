higherSplit = 0.6
lowerSplit = 0.5

module.exports = class RatesService

  base:
    opensource: 20
    private: 40
    nda: 90

  # budget: request.rate
  # requestPricing: type of rate (open-source, private, nda)
  # pricing:
  getRelativeBudget: (budget, requestPricing, pricing) ->
    budget - (@base[requestPricing]-@base[pricing])

  getMaxExpertRate: (budget, pricing) ->
    budget - @base[pricing]


  addRequestSuggestedRates: (request, isCust) ->
    if request.suggested
      for s in request.suggested
        s.suggestedRate = @calcSuggestedRates request, s.expert
    request.base = @base if isCust

  # NOTE suggestedRate is the developers rate
  # not including airpair's margin
  calcSuggestedRates: (request, expert) ->
    if request.status == 'pending' && expert.bookMe?
      return @calcSuggestedBookmeRates request, expert

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

  weight:
    opensource: { opensource:0, private:20, nda:70 }
    private: { opensource:-20, private:0, nda:50 }
    nda: { opensource:-70, private:-50, nda:0 }

  calcSuggestedBookmeRates: (request, expert) ->
    # $log 'calcSuggestedBookmeRates.in', expert
    # $log 'calcSuggestedBookmeRates.in', request.pricing
    pricing = request.pricing
    weight = @weight[pricing]
    rake = expert.bookMe.rake
    rake = 10 if !rake?
    total = request.budget
    # $log 'bookme.calc', pricing, rake, total, weight, expert.bookMe
    r = bookMe: true
    r.opensource =
      total: total+weight.opensource
      expert: @_getExpertByRake total+weight.opensource, rake
    r.private =
      total: total+weight.private
      expert: @_getExpertByRake total+weight.private, rake
    r.nda =
      total: total+weight.nda
      expert: @_getExpertByRake total+weight.nda, rake
    # $log 'bookme.r', r
    r
    # offline:
    #   total: customerRates.offline
    #   expert: customerRates.offline * expertBookMe.rake


  _getExpertByRake: (total, rake) =>
    total - (total*rake/100)








