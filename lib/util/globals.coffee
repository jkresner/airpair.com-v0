global.isProd   = process.env.MONGOHQ_URL?
global.$log     = console.log
global.und      = require 'underscore'
global._        = global.und
global.winston  = require 'winston'   # logging

Mixpanel        = require('mixpanel')
global.mixpanel = Mixpanel.init cfg.analytics.mixpanel.id

require './winstonConfig'

global.und.objectIdsEqual = (uid1, uid2) ->
  return false if !uid1? || !uid2?
  uid1.toString() == uid2.toString()

global.und.idsEqual = global.und.objectIdsEqual