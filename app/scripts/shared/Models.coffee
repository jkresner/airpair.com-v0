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
  # defaults:
    # suggested:      []
    # calls:          []
  validation:
    userId:         { required: true }
    company:        { required: true }
    brief:          { rangeLength: [250, 5000], msg: 'Provide as much detail as possible (min 250 chars) on what you want to work on. Experts ignore requests when they cant tell if they can help.'}
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


class exports.Expert extends BB.SublistModel
  urlRoot: '/api/experts'

  validation:
    userId:         { required: true }
    username:       { required: true }
    brief:          { required: true }
    tags:           { fn: 'validateNonEmptyArray', msg: 'At least one technology tag required' }

  hasLinks: ->
    @get('homepage')? || @get('gh')? || @get('so')? || @get('bb')? || @get('in')? || @get('tw')? || @get('other')? || @get('sideproject')?

  populateFromUser: (user) ->
    pop = {}

    gplus = user.get('google')
    # first time
    if !@get('pic')?
      pop =
        _id:        undefined
        userId:     user.get('_id')
        name:       gplus.displayName
        email:      gplus.emails[0].value
        gmail:      gplus.emails[0].value
        pic:        gplus._json.picture
        timezone:   new Date().toString().substring(25, 45)

    lkIN = user.get('linkedin')
    if lkIN?
      d = in:
        id: lkIN.id
        displayName: lkIN.displayName
      _.extend pop, d

    bb = user.get('bitbucket')
    if bb?
      d = username: bb.id, bb:
        id: bb.id
      _.extend pop, d

    so = user.get('stack')
    if so?
      homepage = so.website_url.replace("http://",'')
      d = username: so.username, homepage: homepage, so:
        id: so.id
        website_url: so.website_url
        link: so.link.replace('http://stackoverflow.com/users/', '')
        reputation: so.reputation
        profile_image: so.profile_image
      _.extend pop, d

    tw = user.get('twitter')
    if tw?
      d = username: tw.username, tw:
        id: tw.id
        username: tw.username
      _.extend pop, d

    gh = user.get('github')
    if gh?
      homepage = gh._json.blog.replace("http://",'')
      d = username: gh.username, homepage: homepage, gh:
        id: gh.id
        username: gh.username
        location: gh._json.location
        blog: gh._json.blog
        gravatar_id: gh._json.gravatar_id
        followers: gh._json.followers
      _.extend pop, d

    @set pop

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