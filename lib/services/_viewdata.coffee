util = require './../../app/scripts/util'
RequestsSvc = require './../services/requests'
ExpertsSvc = require './../services/experts'
TagsSvc = require './../services/tags'
rSvc = new RequestsSvc()
eSvc = new ExpertsSvc()
tSvc = new TagsSvc()

module.exports = class ViewDataService

  session: (user) ->
    if user? && user.google?
      u = _.clone user
      if u.google then delete u.google.token
      if u.twitter then delete u.twitter.token
      if u.bitbucket then delete u.bitbucket.token
      if u.github then delete u.github.token
      if u.stack then delete u.stack.token
    else
      u = authenticated : false

    JSON.stringify u

  review: (id, usr, callback) ->
    rSvc.getByIdSmart id, usr, (r) => callback
      session:    @session usr
      request:    JSON.stringify r
      tagsString: if r? then util.tagsString(r.tags) else 'Not found'

  inbound: (usr, callback) ->
    tSvc.getAll (t) =>
      eSvc.getAll (e) =>
        rSvc.getActive (r) => callback
          session:  @session usr
          requests: JSON.stringify r
          experts:  JSON.stringify e
          tags:     JSON.stringify t