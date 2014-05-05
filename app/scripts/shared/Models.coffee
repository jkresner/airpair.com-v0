BB            = require './../../lib/BB'
objectId2Date = require './mix/objectId2Date'

exports = {}
_.extend exports, require './../tags/Models'
_.extend exports, require './../marketingtags/Models'

class exports.User extends BB.BadassModel
  urlRoot: '/api/users/me'
  authenticated: ->
    @isGoogleAuthenticated()
  isGoogleAuthenticated: ->
    @get('_id')? && @get('google')?


class exports.Company extends BB.BadassModel
  urlRoot: '/api/companys'
  defaults:
    contacts:       []
  validation:
    name:           { required: true }
    about:          { rangeLength: [50, 5000], msg: 'Provide reasonable detail.' }


class exports.CompanyContact extends BB.BadassModel
  validation:
    fullName:       { required: true }
    email:          { required: true, pattern: 'email' }

util = require('../util')

class exports.Request extends BB.SublistModel
  urlRoot: '/api/requests'
  validation:
    userId:         { required: true }
    company:        { required: true }
    brief:          { required: true, msg: 'Provide as much detail as possible (min one sentence / 80 chars) on what you want to work on.'}
    budget:         { required: true }
    availability:   { required: true, msg: 'Please detail your timezone, urgency & availability' }
    tags:           { fn: 'validateNonEmptyArray', msg: 'At least one technology tag required' }
  createdDate: ->
    objectId2Date(@get('_id'))
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
  suggestion: (index) ->
    suggested = @get('suggested')
    if !suggested? || suggested.length is 0 then return null
    s = _.find suggested, (o) -> o.expert._id == index || o.expert.userId == index
    if s? then return s
    suggested[index]
  sortedSuggestions: ->
    orderBy = available: 0, abstained: 1
    _.sortBy @get('suggested'), (s) -> orderBy[s.expertStatus] ? 10
  tagsString: -> util.tagsString @get('tags')
  threeTagsString: -> util.tagsString @get('tags').slice(0, 3)
  isCustomer: (session) ->
    return false if !session.id?
    return true if /iscust/.test(location.href)
    @get('userId') == session.id
  calls: ->
    c = []
    {calls} = @attributes
    if calls? && calls.length > 0
      for call in calls
        call.expert = (_.find @get('suggested'), (o) ->
          o.expert._id == call.expertId).expert
        call.hasRecording = call.recordings? && call.recordings.length > 0
        c.push call
    c

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


class exports.Settings extends BB.BadassModel

  url: -> '/api/settings'

  defaults:
    'paymentMethods': [] # { type: 'paypal', isPrimary: true, info: {} }

  paymentMethod: (index) ->
    pms = @get('paymentMethods')
    if !pms? || pms.length is 0 then return null
    p = _.find pms, (o) -> o.type == index
    if p? then return p
    pms[index]


class exports.Order extends BB.BadassModel
  urlRoot: '/api/orders'
  createdDateString: ->
    moment(@get('utc')).format 'MMM DD'


module.exports = exports
