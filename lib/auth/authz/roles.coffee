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
    uid = req.user._id
    request.userId = uid

  # check google id
  isRequestExpert: (req, request) ->
    uid = req.user._id
    for s in request.suggested
      if s.expert.userId is uid then return true
    false