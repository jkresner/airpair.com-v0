exports = {}


class exports.Lead extends Backbone.Model
  skillList: ->
    skillsShortNames = _.pluck @get('skills'), 'shortName'
    skillList = '';
    skillList += ' ' + s for s in skillsShortNames
    skillList



module.exports = exports