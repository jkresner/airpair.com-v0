CRUDApi = require './_crud'
Skill = require './../models/skill'


class SkillApi extends CRUDApi

  model: Skill

###############################################################################
## Data loading (should be removed soon)
###############################################################################

  clear: -> Skill.find({}).remove()
  boot: (callback) ->
    stubs = require './../app/stubs/skills'
    skills = []
    skills.push name: s.name, shortName: s.shortName, soId: s.soId for s in stubs
    Skill.create skills, (e, r) -> if callback? then callback()

console.log 'SkillApi', SkillApi
console.log 'SkillApi.list', SkillApi.list

skillApi = new SkillApi()

console.log 'Skill', Skill
console.log 'skillApi', skillApi, skillApi.model

module.exports = skillApi