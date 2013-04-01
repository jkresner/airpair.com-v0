BB = require './../../lib/BB'
exports = {}

class SkillsListModel extends BB.BadassModel
  skillSoIdsList: ->
    skillsShortNames = _.pluck @get('skills'), 'soId'
    skillList = '';
    skillList += ',' + s for s in skillsShortNames
    skillList.substring 1, skillList.length


class exports.Skill extends BB.BadassModel
  urlRoot: '/api/skills'


class exports.Company extends BB.BadassModel
  urlRoot: '/api/companys'
  defaults:
    contacts:       []
  validation:
    name:           { required: true }
    about:          { required: true }


class exports.CompanyContact extends BB.BadassModel
  validation:
    fullName:       { required: true }
    email:          { required: true, pattern: 'email' }


class exports.Dev extends SkillsListModel
  urlRoot: '/api/devs'
  defaults:
    rate:           0
  validation:
    name:           { required: true }
    email:          { required: true, pattern: 'email' }
    pic:            { required: true }
    rate:           { required: true, range: [0, 2000] }


class exports.Request extends SkillsListModel
  urlRoot: '/api/requests'
  defaults:
    suggested:      []
    calls:          []
    events:         []
    availability:   []
  validation:
    status:         { required: true }
    companyId:      { required: true }
    companyName:    { required: true }
    brief:          { required: true }
  createdDateString: ->
    if !@get('events')? || @get('events').length < 1
      'create event missing'
    else
      new Date(@get('events')[0].utc).toDateString().replace(' 2013','')
  clearAndSetDefaults: ->
    @clear silent: true
    @set @defaults


module.exports = exports