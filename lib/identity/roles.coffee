adminIds = [
  '117132380360243205600' #JK
  'XXXXXXXXXXXXXXXXXXXXX' #Other
]


module.exports =

  isAdmin: (user) ->
    return false if !user?
    _.contains adminIds, user.googleId


  isRequestOwner: (user, request) ->
    return false if !user?
    _.idsEqual request.userId, user._id


  isRequestExpert: (user, request) ->
    return false if !user?
    for s in request.suggested
      if und.idsEqual s.expert.userId, user._id
        return true
    false