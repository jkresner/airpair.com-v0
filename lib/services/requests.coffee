DomainService   = require './_svc'
Roles           = require './../identity/roles'

publicView: (request) ->
  _.pick request, ['_id','tags','company','brief','availability']

associatedView: (request) ->
  _.pick request, ['_id','tags','company','brief','availability','budget','suggested']


module.exports = class RequestsService extends DomainService

  model: require './../models/request'

  # log event when the request is viewed
  addViewEvent: (request, evt) =>
    up = events: _.clone r.events
    up.events.push evt
    # if evt.name is "expert view"
    #   up.suggested = r.suggested
    #   sug = _.find r.suggested, (s) -> _.idsEqual s.expert.userId, evt.by.id
    #   sug.events.push @newEvent(req, "viewed")
    @model.findByIdAndUpdate request._id, up, (e, r) ->


  getByIdSmart: (id, usr, callback) =>
    @model.findOne { _id: id }, (e, r) =>
      if !r?
        null
      else if Roles.isRequestExpert r, usr
        @addViewEvent r, @newEvent(usr, "expert view")
        associatedView r
      else if Roles.isRequestOwner r, usr
        @addViewEvent r, @newEvent(usr, "customer view")
        associatedView r
      else if Roles.isAdmin usr
        r
      else
        @addViewEvent r, @newEvent(usr, "anon view")
        publicView r