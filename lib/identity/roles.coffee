adminIds = [
  '117132380360243205600' #JK
  '112300854530824394263' #MI
  '117634739628779860480' #DT
  '105314633561185226973' #IL
  '105922668830552511365' #DS
]

adminInitials = {}
adminInitials['117132380360243205600'] = 'jk'
adminInitials['112300854530824394263'] = 'mi'
adminInitials['117634739628779860480'] = 'dt'
adminInitials['105314633561185226973'] = 'il'
adminInitials['105922668830552511365'] = 'ds'

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

  owner2name:
    mi: 'Maksim'
    il: 'Igor'
    dt: 'David'
    jk: 'Jonathon'
    ds: 'Dilys'
