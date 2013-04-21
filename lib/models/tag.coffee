mongoose = require 'mongoose'
Schema = mongoose.Schema

## Chosen to use abbreviations for tag model (eg. short == shortName)
## because of the volume of tags and bloating size of search results

schema = new Schema
  name:           String        # verbose name "Windows Communication Foundation"
  short:          String        # name "wcf" often same same soId or github repo name
  desc:           String        # for ui & extra info
  soId:           String        # stackoverflow tag_name
  so:             String        # stackoverflow tag objects
  ghId:           String        # github repo full_Name
  gh:             Object        # gihub repo object
  tokens:         String        # extra comma separated strings to assist search


module.exports = mongoose.model 'Tag', schema