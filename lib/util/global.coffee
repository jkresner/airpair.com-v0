global.$log   = console.log
global.und    = require 'underscore'
global.und.objectIdsEqual = (uid1, uid2) ->
  if uid1.equals? then uid1.equals(uid2)
  else uid1.toString() == uid2.toString()