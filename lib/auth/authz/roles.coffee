adminIds = [
  '117132380360243205600' #JK
  '105699130570311275819' #MA
]


objectIdsEqual = (uid1, uid2) ->
    if uid1.equals? then uid1.equals(uid2)
    else uid1.toString() == uid2.toString()


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


