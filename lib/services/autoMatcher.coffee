async = require 'async'
AutoMatch = require '../models/autoMatch'
ExpertsService = require './experts'
Mailman = require '../mail/mailman'
moment   = require 'moment'
Order = require '../models/order'
RatesService = require './rates'
Request = require '../models/request'
User = require '../models/user'

module.exports = class AutoMatcher
  logging: on

  expertService: new ExpertsService()
  mailmanService: Mailman # todo: this should probably be changed to an instance
  ratesService: new RatesService()
  user: {}

  notifyExperts: (request, cb) ->
    autoMatch = new AutoMatch(requestId: request.id)
    soTagIds = _.pluck(request.tags, 'soId')
    maxRate = @ratesService.getMaxExpertRate(request.budget, request.pricing)

    @expertService.getByTagsAndMaxRate soTagIds, maxRate, (e, results) =>
      @filter soTagIds, results, (experts) =>
        autoMatch.status = 'failed'
        autoMatch.experts = experts
        if _.any(experts)
          async.each experts, (expert, done) =>
            # email the expert
            @mailmanService.sendAutoNotification(expert, request)
            autoMatch.status = 'completed'
            autoMatch.save done
          , (err) ->
            cb(err, autoMatch)
        else
          cb(null, autoMatch)


  getMatches: (soTagIds, budget, pricing, cb) ->
    maxRate = @ratesService.getMaxExpertRate(budget, pricing)
    @expertService.getByTagsAndMaxRate soTagIds, maxRate, (err, results) =>
      @filter soTagIds, results, (experts) =>
        cb(err, experts)

  # Filters a "superset" of experts that qualify based on their tags and rate
  # and sorts/reduces them according to a proprietary algorithm
  # NOTE: PROCESSES RESULTS IN PARALLEL AND LIMITED TO 100 RESULTS
  filter: (@tags, expertSuperset, cb) ->
    # we work backwards with the tags
    @tags.reverse()

    async.each expertSuperset, @filterIterator, (err) ->
      # sort and limit the scored list of experts
      cb(_.first(_.sortBy(expertSuperset, 'score').reverse(), 50))

  filterIterator: (expert, done) =>
    # start with karma, defaults to 0
    expert.score = expert.karma

    # add an increasing number of points for each tag that matches between request and expert
    # reverse so that the first tag of the request collection gets the most points
    tagPoints = 20
    _.each @tags, (tag) ->
      expert.score += tagPoints if _.contains(_.pluck(expert.tags, 'soId'), tag)
      tagPoints -= 4

    # add weight for StackOverflow reputation
    if expert.so?.reputation? and expert.so.reputation > 0
      expert.score += Math.floor(Math.log(expert.so.reputation))

    # add weight for Github follower count
    if expert.gh?.followers? and expert.gh.followers > 0
      expert.score += Math.floor(Math.log(expert.gh.followers))

    # sort the expert's tags per the tags requested
    expert.tags = _.sortBy expert.tags, (t) =>
      @tags.indexOf(t.soId)

    q =
      calls:
        $elemMatch:
          'expertId' : expert._id

    Request.find(q).lean().exec (err, requests) =>
      calls = _.flatten(_.map(requests, 'calls'))
      if _.any(calls)
        expert.sessionsCount = calls.length
        expert.score += Math.floor(Math.log(calls.length))
        expert.lastSession = moment(_.last(_.sortBy(calls, 'datetime')).datetime).format("MMM D")
      else
        expert.sessionsCount = 0
        expert.lastSession = "n/a"

      done()
