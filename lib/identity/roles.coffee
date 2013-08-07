adminIds = [
  '117132380360243205600' #JK
  '111720348587424235830' #EB
  '112300854530824394263' #MI
]


module.exports =

  isAdmin: (user) ->
    return false if !user?
    _.contains adminIds, user.googleId


  isRequestOwner: (user, request) ->
    return false if !user?
    _.idsEqual request.userId, user._id


  isOrderOwner: (user, order) ->
    return false if !user?
    _.idsEqual order.userId, user._id


  isRequestExpert: (user, request) ->
    return false if !user?
    for s in request.suggested
      if und.idsEqual s.expert.userId, user._id
        return true
    false