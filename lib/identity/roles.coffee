adminIds = [
  '117132380360243205600' #JK gravatar: 19183084115c4a79d34cdc3110adef37
  '105314633561185226973' #IL gravatar: 7345f338d4e79f7d22dac6403beb300c
  '110496794584456738170' #PG gravatar: 2b22b4cd4f65cbef1331cf07e82e6b27
  '108148963133977375684' #TB gravatar: e307e229741052e17d027312a4fe86ca
  '103614010394533051287' #LT
  '104421101970649173838' #AR
  '114831291174925522786' #SH
]


matchmakerIds = [
  '101062250088370367878' #SP
  '106265737415043894759' #MF
  '112631395549975740914' #RP
]


initials = {}
initials['117132380360243205600'] = 'jk'
initials['105314633561185226973'] = 'il'
initials['110496794584456738170'] = 'pg'
initials['108148963133977375684'] = 'tb'
initials['101062250088370367878'] = 'sp' # (Steve Purves)
initials['114831291174925522786'] = 'support' # (Saidur Hossain)
initials['104421101970649173838'] = 'team' # (Alyssa Reese)
initials['106265737415043894759'] = 'mf' # (Martin Feckie)
initials['112631395549975740914'] = 'rp' # (Ramon Porter)

initials['103614010394533051287'] = 'lt'
initials['105922668830552511365'] = 'ds'
initials['112300854530824394263'] = 'mi'
initials['102299765632981130643'] = 'er'

module.exports =

  isAdmin: (user) ->
    return false if !user?
    _.contains adminIds, user.googleId

  isMatchmaker: (user) ->
    return false if !user?
    return true if _.contains adminIds, user.googleId
    _.contains matchmakerIds, user.googleId

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

  getAdminEmails: ->
    _.map adminIds, (id) -> "#{initials[id]}@airpair.com"

  getAdminInitials: (googleId) ->
    initials[googleId]

  owner2name:
    jk: 'Jonathon'
    il: 'Igor'
    pg: 'Prateek'
    tb: 'Tyler'
    lt: 'Lissanthea'
    ds: 'Dilys'
    mi: 'Maksim'
    dt: 'David'
    er: 'Ed'
