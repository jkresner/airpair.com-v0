mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
  name:         String
  email:        { type: String, index: true }
  pic:          String
  githubId:     Number
  github:       {}
  googleId:     String
  google:       {}
  twitterId:    Number
  twitter:      {}
  linkedinId:   String
  linkedin:     {}
  stackId:      Number
  stack:        {}
  bitbucketId:  String
  bitbucket:    {}

module.exports = mongoose.model 'User', schema