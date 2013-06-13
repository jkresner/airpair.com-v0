adminIds = [
  '117132380360243205600' #JK
  '105699130570311275819' #MA
]


module.exports =

  # check google id
  isAdmin: (req) ->
    return false if !req.user?
    und.contains adminIds, req.user.googleId

  # check google id
  isRequestOwner: (req, request) ->
    return false if !req.user?
    # $log 'isRequestOwner', request.userId, req.user._id
    und.objectIdsEqual request.userId, req.user._id

  # check google id
  isRequestExpert: (req, request) ->
    return false if !req.user?
    uid = req.user._id
    for s in request.suggested
      if und.idsEqual s.expert.userId, uid then return true
    false


