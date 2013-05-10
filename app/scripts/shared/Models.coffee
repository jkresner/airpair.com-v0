BB = require './../../lib/BB'
exports = {}

_.extend exports, require './../tags/Models'


class exports.User extends BB.BadassModel
  urlRoot: '/api/users/me'
  isGoogleAuthenticated: ->
    @get('_id')? && @get('google')?


class exports.Company extends BB.BadassModel
  urlRoot: '/api/companys'
  defaults:
    contacts:       []
  validation:
    name:           { required: true }
    about:          { rangeLength: [140, 5000], msg: 'Provide reasonable detail (min 140 chars) about your company so experts can asses if they are a good match. Sometimes we find you experts that have both technical & relevant industry experience.' }


class exports.CompanyContact extends BB.BadassModel
  validation:
    fullName:       { required: true }
    email:          { required: true, pattern: 'email' }


class exports.Request extends BB.SublistModel
  urlRoot: '/api/requests'
  validation:
    userId:         { required: true }
    company:        { required: true }
    brief:          { rangeLength: [200, 5000], msg: 'Provide as much detail as possible (min 200 chars) on what you want to work on. Experts ignore requests when they cant tell if they can help.'}
    budget:         { required: true }
    availability:   { required: true, msg: 'Please detail your timezone, urgency & availability' }
    tags:           { fn: 'validateNonEmptyArray', msg: 'At least one technology tag required' }
  createdDate: ->
    if !@get('events')? || @get('events').length < 1 then return new Date()
    new Date(@get('events')[0].utc)
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
  contact: (index) ->
    # first try lookup by fullName
    contacts = @get('company').contacts
    if !contacts? || contacts.length is 0 then return null
    c = _.find contacts, (c) -> c.fullName == index
    if c? then return c
    contacts[index]


class exports.Expert extends BB.SublistModel
  urlRoot: '/api/experts'
  validation:
    userId:         { required: true }
    username:       { required: true }
    brief:          { required: true, msg: 'Let us know the types of work you want to do, so we can match you with stimulating challenges.' }
    tags:           { fn: 'validateNonEmptyArray', msg: 'At least one technology tag required' }

  hasLinks: ->
    @get('homepage')? || @get('gh')? || @get('so')? || @get('bb')? || @get('in')? || @get('tw')? || @get('other')? || @get('sideproject')?

  getHomepageUrl: (val) ->
    url = null
    url = val.replace("https://",'').replace("http://",'') if val?
    url

  toggleTag: (value) ->
    # so we only save what we need and don't bloat the requests
    tag =
      _id: value._id
      name: value.name
      short: value.short
      soId: value.soId
      ghId: value.ghId
    @toggleAttrSublistElement 'tags', tag, (m) -> m._id is value._id


module.exports = exports