BB = require './../../lib/BB'
exports = {}

_.extend exports, require './../tags/Models'



class exports.User extends BB.BadassModel
  urlRoot: '/api/users/me'
  isGoogleAuthenticated: ->
    @get('_id')? && @get('google')?


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

class exports.Request extends BB.SublistModel
  urlRoot: '/api/requests'
  defaults:
    # tags:           []
    suggested:      []
    calls:          []
    events:         []
    availability:   []
  validation:
    status:         { required: true }
    userId:         { required: true }
    companyId:      { required: true }
    companyName:    { required: true }
    brief:          { required: true }
    budget:         { required: true }
    tags:           { fn: 'validateTags', msg: 'At least one technology tag required' }
    availability:   { required: true, msg: 'At least one time slot is required' }
  validateTags: (value, attr, computedState) ->
    console.log 'validateTags', value, attr, computedState
    if !value? || value.length is 0 then true
  createdDateString: ->
    if !@get('events')? || @get('events').length < 1
      'create event missing'
    else
      new Date(@get('events')[0].utc).toDateString().replace(' 2013','')
  toggleTag: (value) ->
    @toggleAttrSublistElement 'tags', value, (m) -> m._id is value._id
  toggleAvailability: (value) ->
    @toggleAttrSublistElement 'availability', value, (m) -> m is value


module.exports = exports