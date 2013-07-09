DomainService   = require './_svc'
SettingsSvc = require './../services/settings'

module.exports = class SettingsService extends DomainService

  model: require './../models/settings'


