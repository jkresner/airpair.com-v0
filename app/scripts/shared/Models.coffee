BB = require './../../lib/BB'
exports = {}


class exports.User extends BB.BadassModel
  urlRoot: '/api/users/me'


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


class exports.Request extends BB.BadassModel
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


module.exports = exports