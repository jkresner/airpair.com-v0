exports = {}


class exports.Skill extends Backbone.Model


class exports.Dev extends Backbone.Model
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



class exports.Lead extends Backbone.Model
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