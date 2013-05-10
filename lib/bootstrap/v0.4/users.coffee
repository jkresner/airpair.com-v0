User = require './../models/user'
v0_4_users = require './data/v0.4/users'

# step 1 :: load in devs from v0 (to maintain original ids)
importUsersV0_4 = (callback) ->
  count = 0
  for d in v0_4_users
    new User( d ).save (e, r) =>
      if e? then $log "added[#{count}]", e, r
      count++
      if count == v0_4_users.length-1 then callback()

module.exports = (callback) ->
  User.find({}).remove ->
    $log 'u[0] user removed'
    User.collection.dropAllIndexes (e, r) ->
      $log "u[1] adding #{v0_4_users.length} v0_4_users"
      importUsersV0_4 ->
        User.find {}, (e, r) ->
          $log "u[2] saved #{r.length} users"
          callback r