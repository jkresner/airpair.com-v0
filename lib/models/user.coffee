mongoose = require 'mongoose'
Schema   = mongoose.Schema

User = new Schema
  name:         String
  email:        String
  pic:          String
  githubId:     Number
  github:       {}
  googleId:     { required: true, type: String, index: { unique: true, dropDups: true } }
  google:       {}
  twitterId:    Number
  twitter:      {}
  linkedinId:   String
  linkedin:     {}
  stackId:      Number
  stack:        {}
  bitbucketId:  String
  bitbucket:    {}
  referrer:     {}
  cohort:       {}
  #  mixpanel:
  #    id:
  #    utm:
  #    data: exported from mixpanel

module.exports = mongoose.model 'User', User
