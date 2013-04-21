CRUDApi = require './_crud'


class SkillApi extends CRUDApi

  model: require './../../models/v0/skill'


module.exports = (app) -> new SkillApi app,'skills'