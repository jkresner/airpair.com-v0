adminIds = [
  '117132380360243205600' #JK
  '105699130570311275819' #MA
]


module.exports =

  # check google id
  isAdmin: (req) ->
    und.contains adminIds, req.user.googleId

  # check google id
  isRequestOwner: (req, request) ->
    # $log 'isRequestOwner', request.userId, req.user._id
    und.objectIdsEqual request.userId, req.user._id

  # check google id
  isRequestExpert: (req, request) ->
    uid = req.user._id
    for s in request.suggested
      if und.objectIdsEqual s.expert.userId, uid then return true
    false


