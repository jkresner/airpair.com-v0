adminIds = [
  '117132380360243205600' #JK
  '117634739628779860480' #EM
  '105314633561185226973' #IL
  '105922668830552511365' #DS
  '112300854530824394263' #MI
]

adminInitials = {}
adminInitials['117132380360243205600'] = 'jk'
adminInitials['100358155378996572027'] = 'em'
adminInitials['105314633561185226973'] = 'il'
adminInitials['105922668830552511365'] = 'ds'
adminInitials['112300854530824394263'] = 'mi'

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
    il: 'Igor'
    em: 'Eoin'
    jk: 'Jonathon'
    ds: 'Dilys'
    mi: 'Maksim'
