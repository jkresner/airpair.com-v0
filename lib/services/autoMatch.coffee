ExpertsService        = require './experts'
RatesService          = require './rates'
SettingsService       = require './settings'


module.exports = class AutoMatchService

  logging: on

  mailmanService:  require '../mail/mailman'
  expertService:   new ExpertsService()
  ratesService:    new RatesService()
  settingsService: new SettingsService()

  sendExpertNotifications: (request, done) ->
    soTagIds = _.pluck(request.tags, 'soId')
    maxRate = @ratesService.getMaxExpertRate(request.budget, request.pricing)

    @expertService.getByTagsAndMaxRate soTagIds, maxRate, (e, results) =>
      @pickFiveBestExperts results, (matchedExperts) =>
        for expert in matchedExperts
          @mailmanService.sendAutoNotification expert, request
        done()

  pickFiveBestExperts: (superset, cb) ->
    # whatever the algorithm does
    matches = _.first(superset, 5)
    cb matches
