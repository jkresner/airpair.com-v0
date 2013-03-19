mongoose = require 'mongoose'
Schema = mongoose.Schema
# ObjectId = Schema.ObjectId;


getSkills = (list) -> list.join ','
setSkills = (list) -> list.split ','


schema = new Schema
  # thread: ObjectId
  # date: {type: Date, default: Date.now}
  # author: {type: String, default: 'Anon'}
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
  skills:       []          #, get: getSkills, set: setSkills }
  rate:         Number



module.exports = mongoose.model 'Dev', schema