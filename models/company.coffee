mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
  name:       String
  url:        String
  about:      String
  contacts:   []

module.exports = mongoose.model 'Company', schema