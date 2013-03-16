BB = require './../../lib/BB'
exports = {}

class exports.Skill extends BB.BadassModel


class exports.Dev extends BB.BadassModel
  skillList: ->
    skillsShortNames = _.pluck @get('skills'), 'soId'
    skillList = '';
    skillList += ' ' + s for s in skillsShortNames
    skillList
  skillListLabeled: ->
    skillsShortNames = _.pluck @get('skills'), 'soId'
    skillList = '';
    skillList += '<span class="label label-skill">' + s + "</span>" for s in skillsShortNames
    skillList


class exports.Company extends BB.BadassModel
  urlRoot: '/api/companys'
  defaults:
    contacts:   []
  validation:
    name:           { required: true }
    about:          { required: true }


class exports.CompanyContact extends BB.BadassModel
  validation:
    fullName:       { required: true }
    email:          { required: true, pattern: 'email' }


class exports.Lead extends BB.BadassModel
  skillList: ->
    skillsShortNames = _.pluck @get('skills'), 'shortName'
    skillList = '';
    skillList += ' ' + s for s in skillsShortNames
    skillList
  skillListLabeled: ->
    skillsShortNames = _.pluck @get('skills'), 'shortName'
    skillList = '';
    skillList += '<span class="label label-skill">' + s + "</span>" for s in skillsShortNames
    skillList


module.exports = exports