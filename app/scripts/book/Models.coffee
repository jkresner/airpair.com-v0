BB      = require './../../lib/BB'
Shared  = require './../shared/Models'
exports = {}

exports.User = Shared.User
exports.Expert = Shared.Expert
exports.Settings = Shared.Settings

exports.Request = class Request extends Shared.Request

  defaults:
    pricing: 'private'

  opensource: -20
  private: 0
  nda: 50

  validation:
    userId:         { required: true }
    # company:        { required: true }
    brief:          { required: true, msg: 'Provide as much detail as possible (min one sentence / 80 chars) on what you want to work on.'}
    budget:         { required: true }
    # availability:   { required: true, msg: 'Please detail your timezone, urgency & availability' }
    # tags:           { fn: 'validateNonEmptyArray', msg: 'At least one technology tag required' }


module.exports = exports
