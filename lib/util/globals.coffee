global.config         = require('./appConfig')[process.env.Env || 'dev']
global.$log           = console.log

global._              = require 'lodash'
global._.pickNested   = require '../mix/pickNested'
global._.idsEqual     = require '../mix/idsEqual'

global.restler        = require('restler')

global.winston        = require 'winston'   # logging
require './winstonConfig'             # setup logging configuration / plugins
winston.error "app restart" if config.isProd  # log application restart/ send email notification

SegmentIo              = require('analytics-node')
global.segmentio       = new SegmentIo config.analytics.segmentio.writeKey
segmentio.track
  userId: '0'
  event: 'app restart'


crypto = require('crypto')
global.md5 = (str, encoding) ->
  crypto
    .createHash('md5')
    .update(str, 'utf8')
    .digest(encoding || 'hex')

global.gravatarLnk = (email) ->
  "//0.gravatar.com/avatar/#{md5(email)}"
