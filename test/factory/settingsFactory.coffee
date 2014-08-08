global._ = require 'lodash'
Factory = require('factory-lady')
SettingsModel = require('../../lib/models/settings')

Factory.define 'settings', SettingsModel, defaults =
  paymentMethods: [
    isPrimary: true
    type: "stripe"
    info: { card: "4242" }
  ]
