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
  # defaults:
    # suggested:      []
    # calls:          []
  validation:
    userId:         { required: true }
    company:        { required: true }
    brief:          { required: true, msg: 'A detailed brief is required' }
    budget:         { required: true }
    availability:   { fn: 'validateNonEmptyArray', msg: 'At least one time slot is required' }
    tags:           { fn: 'validateNonEmptyArray', msg: 'At least one technology tag required' }
  createdDate: ->
    if !@get('events')? || @get('events').length < 1 then return new Date()
    new Date(@get('events')[0])
  createdDateString: ->
    moment(@createdDate()).format 'MMM DD'
  toggleTag: (value) ->
    # so we only save what we need and don't bloat the requests
    tag =
      _id: value._id
      name: value.name
      short: value.short
      soId: value.soId
      ghId: value.ghId
    @toggleAttrSublistElement 'tags', tag, (m) -> m._id is value._id
  toggleAvailability: (value) ->
    @toggleAttrSublistElement 'availability', value, (m) -> m is value


module.exports = exports