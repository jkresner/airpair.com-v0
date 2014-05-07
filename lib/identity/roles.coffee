adminIds = [
  '117132380360243205600' #JK
  '105314633561185226973' #IL
  '105922668830552511365' #DS
  '103614010394533051287' #LT
  '110496794584456738170' #PG
  # '110496794584456738170' #TB
]


matchmakerIds = [
  '101062250088370367878' #SP
]


initials = {}
initials['117132380360243205600'] = 'jk'
initials['105314633561185226973'] = 'il'
initials['103614010394533051287'] = 'lt'
initials['110496794584456738170'] = 'pg'
initials['105922668830552511365'] = 'ds'
initials['112300854530824394263'] = 'mi'
initials['102299765632981130643'] = 'er'
# initials['102299765632981130643'] = 'tb'
initials['101062250088370367878'] = 'sp' # (Steve Purves)


module.exports =

  isAdmin: (user) ->
    return false if !user?
    _.contains adminIds, user.googleId

  isMatchmaker: (user) ->
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
    initials[googleId]

  owner2name:
    il: 'Igor'
    lt: 'Lissanthea'
    jk: 'Jonathon'
    jk: 'Prateek'
    ds: 'Dilys'
    mi: 'Maksim'
    dt: 'David'
    er: 'Ed'
