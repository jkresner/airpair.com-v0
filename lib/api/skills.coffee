CRUDApi = require './_crud'


class SkillApi extends CRUDApi

  model: require './../models/skill'


module.exports = (app) -> new SkillApi app,'skills'