module.exports =
idsEqual = (uid1, uid2) ->
  return false if !uid1? || !uid2?
  uid1.toString() == uid2.toString()
