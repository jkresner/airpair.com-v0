global.cfg      = cfg  # cfg is already declared in util/appConfig
global.$log     = console.log

global._        = require 'lodash'
global._.idsEqual = require '../../app/scripts/shared/mix/idsEqual'

global.winston  = require 'winston'   # logging
require './winstonConfig'             # setup logging configuration / plugins
winston.error "app restart" if cfg.isProd  # log application restart/ send email notification

Mixpanel        = require 'mixpanel'
global.mixpanel = Mixpanel.init cfg.analytics.mixpanel.id
mixpanel.track 'app restart'
