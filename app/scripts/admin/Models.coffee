exports = {}


class exports.Lead extends Backbone.Model
  skillList: ->
    skillsShortNames = _.pluck @get('skills'), 'shortName'
    skillList = '';
    skillList += ' ' + s for s in skillsShortNames
    skillList
  skillListLabeled: ->
    skillsShortNames = _.pluck @get('skills'), 'shortName'
    skillList = '';
    skillList += '<span class="label">' + s + "</span>" for s in skillsShortNames
    skillList


module.exports = exports