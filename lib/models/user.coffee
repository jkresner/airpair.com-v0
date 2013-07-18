mongoose = require 'mongoose'
Schema = mongoose.Schema

User = new Schema
  name:         String
  email:        String
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
  referrer:     {}


module.exports = mongoose.model 'User', User