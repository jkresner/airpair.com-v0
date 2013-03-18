CRUDApi = require './_crud'


class SkillApi extends CRUDApi

  model: require './../models/skill'

###############################################################################
## Data loading (should be removed soon)
###############################################################################

  clear: -> Skill.find({}).remove()
  boot: (callback) ->
    stubs = require './../app/stubs/skills'
    skills = []
    skills.push name: s.name, shortName: s.shortName, soId: s.soId for s in stubs
    @model.create skills, (e, r) -> if callback? then callback()


module.exports = new SkillApi()