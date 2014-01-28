mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
  access_token: String

module.exports = mongoose.model 'GoogleAccessToken', schema
