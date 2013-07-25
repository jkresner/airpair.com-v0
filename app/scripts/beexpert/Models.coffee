BB = require './../../lib/BB'
Shared = require './../shared/Models'
exports = {}

exports.User = Shared.User

class exports.Expert extends Shared.Expert
  setFromUser: (user) ->
    data = {}
    @clearV03Details()

    # first time
    if !@get('userId')? then data = @fromGPlus user.get('google'), user.id

    _.extend data, @fromLinkedin user.get 'linkedin'
    _.extend data, @fromBitbucket user.get 'bitbucket'
    _.extend data, @fromStack user.get 'stack'
    _.extend data, @fromTwitter user.get 'twitter'
    _.extend data, @fromGithub user.get 'github'

    @trySetPic data

    @set data

  # cause fresh social profile data & wipe v0.3 junk
  clearV03Details: ->
    for p in ['so','gh','in']
      if @get(p)? && !@get(p).id? then @unset p, silent: true

  # try set pic from alternate sources if google plus image is null
  trySetPic: (pop) ->
    if !pop.pic? && pop.gh? && pop.gh.gravatar_id?
      pop.pic = "https://secure.gravatar.com/avatar/#{pop.gh.gravatar_id}"
    if !pop.pic? && pop.so? && pop.so.profile_image?
      pop.pic = pop.so.profile_image
    if !pop.pic? && pop.tw? && pop.tw.pic?
      pop.pic = pop.tw.pic.value

  fromGPlus: (gplus, userId) ->
    _id:        undefined  # wipe over 'me'
    userId:     userId
    name:       gplus.displayName
    email:      gplus.emails[0].value
    gmail:      gplus.emails[0].value
    pic:        gplus._json.picture
    timezone:   new Date().toString().substring(25, 45)

  fromLinkedin: (lkIN) ->
    if lkIN?
      in: { id: lkIN.id, displayName: lkIN.displayName }

  fromBitbucket: (bb) ->
    if bb?
      username: bb.id, bb: { id: bb.id }

  fromStack: (so) ->
    if so?
      homepage = @getHomepageUrl(so.website_url)
      username: so.username, homepage: homepage, so:
        id: so.id
        website_url: so.website_url
        link: so.link.replace('http://stackoverflow.com/users/', '')
        reputation: so.reputation
        profile_image: so.profile_image

  fromTwitter: (tw) ->
    if tw?
      username: tw.username, tw: { id: tw.id, username: tw.username, pic: tw.photos[0] }

  fromGithub: (gh) ->
    if gh?
      homepage = @getHomepageUrl(gh._json.blog)
      username: gh.username, homepage: homepage, gh:
        id: gh.id
        username: gh.username
        location: gh._json.location
        blog: gh._json.blog
        gravatar_id: gh._json.gravatar_id
        followers: gh._json.followers


module.exports = exports