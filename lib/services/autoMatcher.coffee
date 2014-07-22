AutoMatch = require '../models/autoMatch'
ExpertsService = require './experts'
RatesService = require './rates'
Mailman = require '../mail/mailman'
User = require '../models/user'

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
      @filter results, (experts) =>
        @autoMatch.experts = experts
        if experts.length
          for expert in experts
            Mailman.sendAutoNotification expert, request
          @autoMatch.status = 'completed'
        else
          @autoMatch.status = 'failed'
        @autoMatch.save =>
          cb(@autoMatch)

  filter: (superset, cb) ->
    _.each superset, (expert) =>
      # start with karma, defaults to 0
      expert.score = expert.karma

      # add a point for each tag that matches between request and expert
      expert.score += _.intersection(_.pluck(@request.tags, 'soId'), _.pluck(expert.tags, 'soId')).length

      # add weightings for different social indicators
      # expert.score += @githubFollowerPoints(expert)

    # return sorted list of experts
    cb(_.sortBy(superset, 'score'))

  # githubFollowerPoints: (expert) ->
  #   if expert?
  #     usersService.for expert, (user) ->
  #       user.github

  #   else
  #     0


