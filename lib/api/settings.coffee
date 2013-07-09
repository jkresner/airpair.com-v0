CRUDApi = require './_crud'


class SettingsApi extends CRUDApi

  model: require './../models/settings'


module.exports = (app) -> new SettingsApi app, 'settings'