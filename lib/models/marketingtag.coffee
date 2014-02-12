mongoose = require 'mongoose'
Schema   = mongoose.Schema

schema = new Schema

  name:      { required: true, type: String, index: { unique: true, dropDups: true } }
  type:      { required: true, type: String }
  group:     { type: String, default: '' }

module.exports = mongoose.model 'MarketingTag', schema
