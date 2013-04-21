mongoose = require 'mongoose'
Schema = mongoose.Schema


schema = new Schema
  name:         String
  email:        String
  gmail:        String
  pic:          String
  homepage:     String      # homepage
  gh:           String      # github
  so:           String      # stackoverflow
  bb:           String      # bitbucket
  in:           String      # linkedIn
  other:        String
  skills:       []
  rate:         Number



module.exports = mongoose.model 'Dev', schema