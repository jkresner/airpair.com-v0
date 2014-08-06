adminIds = [
  '117132380360243205600' #JK gravatar: 19183084115c4a79d34cdc3110adef37
  '105314633561185226973' #IL gravatar: 7345f338d4e79f7d22dac6403beb300c
  '110496794584456738170' #PG gravatar: 2b22b4cd4f65cbef1331cf07e82e6b27
  '104421101970649173838' #AR
  '114831291174925522786' #SH
  '105976516028706632944' #OF gravatar: c5f6a1b002347ea69a0cba7e4c0da508
  '116906489186772028226' #DU gravatar: e9b01bb34761b9927cf29753e8927010
  '103040640713677687595' #EM gravatar:
  '104255454895680152796' #JM gravatar:
]

pipelinerIds = [
  '114831291174925522786' #TEAM
  '117132380360243205600' #JK gravatar: 19183084115c4a79d34cdc3110adef37
  '105314633561185226973' #IL gravatar: 7345f338d4e79f7d22dac6403beb300c
  '110496794584456738170' #PG gravatar: 2b22b4cd4f65cbef1331cf07e82e6b27
  '105976516028706632944' #OF gravatar: c5f6a1b002347ea69a0cba7e4c0da508
  '116906489186772028226' #DU gravatar: e9b01bb34761b9927cf29753e8927010
]

matchmakerIds = [
  '101062250088370367878' #SP
  '106265737415043894759' #MF
  '112631395549975740914' #RP
]

# AirPair Hall Of Fame
initials = {}
initials['117132380360243205600'] = 'jk'
initials['105314633561185226973'] = 'il'
initials['110496794584456738170'] = 'pg'
initials['105976516028706632944'] = 'of'
initials['116906489186772028226'] = 'du'
initials['103040640713677687595'] = 'em'
initials['104255454895680152796'] = 'jm'
initials['108148963133977375684'] = 'tb'
initials['101062250088370367878'] = 'sp' # (Steve Purves)
initials['114831291174925522786'] = 'support' # (Saidur Hossain)
initials['104421101970649173838'] = 'team' # (Alyssa Reese)
initials['106265737415043894759'] = 'mf' # (Martin Feckie)
initials['112631395549975740914'] = 'rp' # (Ramon Porter)
initials['103614010394533051287'] = 'lt' # (Lissanthea Taylor)
initials['105922668830552511365'] = 'ds' # (Dilys Sun)
initials['112300854530824394263'] = 'mi' # (M Ioffee)
initials['102299765632981130643'] = 'er' # (E Roman)

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

  getPipelinerEmails: ->
    _.map pipelinerIds, (id) -> "#{initials[id]}@airpair.com"

  getAdminEmails: ->
    _.map adminIds, (id) -> "#{initials[id]}@airpair.com"

  getAdminInitials: (googleId) ->
    initials[googleId]

  owner2name:
    jk: 'Jonathon'
    il: 'Igor'
    pg: 'Prateek'
    of: 'Obie'
    du: 'Daniel'
    tb: 'Tyler'
    lt: 'Lissanthea'
    ds: 'Dilys'
    mi: 'Maksim'
    dt: 'David'
    er: 'Ed'
