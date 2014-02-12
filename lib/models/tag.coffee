mongoose = require 'mongoose'
Schema   = mongoose.Schema

## Chosen to use abbreviations for tag model (eg. short == shortName)
## because of the volume of tags and bloating size of search results

schema = new Schema

  name:      { required: true, type: String }   # verbose name "Windows Communication Foundation"
  short:     { required: true, type: String }   # short name "wcf" often same same soId or github repo name
  desc:      String        # for ui & extra info
  soId:      { type: String, unique: true, sparse: true }         # stackoverflow tag_name
  so:        {}            # stackoverflow tag object
  ghId:      { type: String, unique: true, sparse: true }        # github repo full_Name
  gh:        {}            # gihub repo object
  tokens:    String        # extra comma separated strings to assist search


module.exports = mongoose.model 'Tag', schema
