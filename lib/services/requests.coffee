DomainService   = require './_svc'
Roles           = require './../identity/roles'


module.exports = class RequestsService extends DomainService

  model: require './../models/request'


  publicView: (request) ->
    _.pick request, ['_id','tags','company','brief','availability']

  associatedView: (request) ->
    _.pick request, ['_id','tags','company','brief','availability','budget','suggested']


  # log event when the request is viewed
  addViewEvent: (request, usr, evtName) =>
    evt = @newEvent usr, evtName
    up = { events: _.clone(request.events) }
    up.events.push evt
    if evt.name is "expert view"
      up.suggested = request.suggested
      sug = _.find request.suggested, (s) -> _.idsEqual s.expert.userId, evt.by.id
      sug.events.push @newEvent(usr, "viewed")
    @model.findByIdAndUpdate request._id, up, (e, r) ->


  getByIdSmart: (id, usr, callback) =>
    @model.findOne { _id: id }, (e, r) =>
      request = null

      if r?
        if Roles.isRequestExpert usr, r
          @addViewEvent r, usr, "expert view"
          request = @associatedView r
        else if Roles.isRequestOwner usr, r
          @addViewEvent r, usr, "customer view"
          request = r
        else if Roles.isAdmin usr
          request = r
        else
          @addViewEvent r, usr, "anon view"
          request = @publicView r

      callback request