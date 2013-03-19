mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
  name:           String        # used for verboseness
  shortName:      String        # used for airpair admin
  soId:           String        # used for the users view

module.exports = mongoose.model 'Skill', schema