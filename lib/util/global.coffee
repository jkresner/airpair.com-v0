global.$log   = console.log
global.und    = require 'underscore'

global.und.objectIdsEqual = (uid1, uid2) ->
  return false if !uid1? || !uid2?
  uid1.toString() == uid2.toString()

global.und.idsEqual = global.und.objectIdsEqual