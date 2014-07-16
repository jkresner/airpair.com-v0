async                 = require 'async'
Data                  = require './requests.query'
Roles                 = require '../identity/roles'
DomainService         = require './_svc'
RatesService          = require './rates'
ExpertsService        = require './experts'
SettingsService       = require './settings'
MarketingTagsSvc      = require './marketingtags'
expertPick            = require '../mix/expertForSuggestion'
objectIdWithTimestamp = require '../mix/objectIdWithTimestamp'


module.exports = class AutoMatchService extends DomainService

  logging: on

  mailman:      require '../mail/mailman'
  rates:        new RatesService()
  experts:      new ExpertsService()

  sendAutoNotifications: (request) ->

    experts.getBySubscriptions(tagId, level, cb)
      mailman.autoMatchNotification expert, request
