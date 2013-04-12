mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
  name:         String
  email:        String
  pic:          String
  githubId:     Number
  github:       {}
  googleId:     String
  google:       {}

module.exports = mongoose.model 'User', schema