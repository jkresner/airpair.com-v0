global.cfg      = cfg  # cfg is already declared in util/appConfig 
global.$log     = console.log

global._        = require 'underscore'
global._.idsEqual = (uid1, uid2) ->
  return false if !uid1? || !uid2?
  uid1.toString() == uid2.toString()

global.winston  = require 'winston'   # logging
require './winstonConfig'             # setup logging configuration / plugins
winston.error "app restart" if cfg.isProd  # log application restart/ send email notification

Mixpanel        = require 'mixpanel'
global.mixpanel = Mixpanel.init cfg.analytics.mixpanel.id
mixpanel.track 'app restart'