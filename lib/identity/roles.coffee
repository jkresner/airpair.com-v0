adminIds = [
  '117132380360243205600' #JK
  '112300854530824394263' #MI
  '113874948210413798988' #DT
  '105821070919354205173‎' # IL
]

adminInitials = {}
adminInitials['117132380360243205600'] = 'jk'
adminInitials['112300854530824394263'] = 'mi'
adminInitials['113874948210413798988'] = 'dt'
adminInitials['105821070919354205173'] = 'il'

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
      if _.idsEqual s.expert.userId, user._id
        return true
    false

  getAdminInitials: (googleId) ->
    adminInitials[googleId]
