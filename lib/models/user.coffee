mongoose = require 'mongoose'
Schema   = mongoose.Schema

User = new Schema
  name:         String
  email:        { type: String, unique: true, sparse: true, trim: true, lowercase: true },
  pic:          String
  githubId:     Number
  github:       {}
  googleId:     { type: String, sparse: true, unique: true, dropDups: true },
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
