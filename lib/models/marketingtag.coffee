mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema

  name:      { required: true, type: String }
  # type:      { required: true, type: String }
  # group:     { required: true, type: String }

module.exports = mongoose.model 'MarketingTag', schema
