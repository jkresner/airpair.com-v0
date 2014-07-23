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
  user: {}

  constructor: (@user) ->

  notifyExperts: (@request, cb) ->
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

  getMatches: (soTagIds, budget, pricing, cb) ->
    maxRate = @ratesService.getMaxExpertRate(budget, pricing)
    @expertService.getByTagsAndMaxRate soTagIds, maxRate, (err, results) =>
      @filter soTagIds, results, (experts) =>
        console.log 'experts.length', experts.length, cb
        cb(err, experts)

  filter: (tags, superset, cb) ->
    console.log 'superset length', superset.length
    _.each superset, (expert) =>
      # start with karma, defaults to 0
      expert.score = expert.karma

      # add an increasing number of points for each tag that matches between request and expert
      # reverse so that the first tag of the request collection gets the most points
      tagPoints = 1
      _.each tags.reverse(), (tag) ->
        expert.score += tagPoints if _.contains(_.pluck(expert.tags, 'soId'), tag)
        tagPoints++

      console.log 'filter result for ', expert.name, expert.score
      # add weightings for different social indicators
      # expert.score += @githubFollowerPoints(expert)

    # return sorted list of experts
    cb(_.sortBy(superset, 'score').reverse())
