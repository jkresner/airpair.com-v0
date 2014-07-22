global.config         = require('./appConfig')[process.env.Env || 'dev']
global.$log           = console.log

global._              = require 'lodash'
global._.pickNested   = require '../mix/pickNested'
global._.idsEqual     = require '../mix/idsEqual'

global.winston        = require 'winston'   # logging
require './winstonConfig'             # setup logging configuration / plugins
winston.error "app restart" if config.isProd  # log application restart/ send email notification

SegmentIo              = require('analytics-node')
global.segmentio       = new SegmentIo config.analytics.segmentio.writeKey
segmentio.track
  userId: '0'
  event: 'app restart'
