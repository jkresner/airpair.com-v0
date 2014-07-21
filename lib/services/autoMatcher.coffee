AutoMatch = require '../models/autoMatch'
ExpertsService = require './experts'
RatesService = require './rates'
Mailman = require '../mail/mailman'

module.exports = class AutoMatcher
  logging: on

  expertService: new ExpertsService()
  mailmanService: Mailman # todo: this should probably be changed to an instance
  ratesService: new RatesService()

  constructor: (@request, cb) ->
    @autoMatch = new AutoMatch(requestId: request.id)
    soTagIds = _.pluck(request.tags, 'soId')
    maxRate = @ratesService.getMaxExpertRate(request.budget, request.pricing)

    @expertService.getByTagsAndMaxRate soTagIds, maxRate, (e, results) =>
      @pickFiveBestExperts results, (experts) =>
        @autoMatch.experts = experts
        if experts.length
          for expert in experts
            Mailman.sendAutoNotification expert, request
          @autoMatch.status = 'completed'
        else
          @autoMatch.status = 'failed'
        @autoMatch.save =>
          cb(@autoMatch)

  pickFiveBestExperts: (superset, cb) ->
    # whatever the algorithm does
    matches = _.first(superset, 5)
    cb matches
