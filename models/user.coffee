mongoose = require 'mongoose'
Schema = mongoose.Schema


schema = new Schema
  name:         String
  email:        String
  pic:          String
  githubId:     Number
  github:       {}      # github
  googleId:     String
  google:       {}      # google


module.exports = mongoose.model 'User', schema