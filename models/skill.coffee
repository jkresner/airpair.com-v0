mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
  name: String
  shortName: String
  soId: String

module.exports = mongoose.model 'Skill', schema