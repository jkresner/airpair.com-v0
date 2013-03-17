mongoose = require 'mongoose'
Schema = mongoose.Schema

Contact = new Schema
  fullName:   String
  email:      String
  title:      String
  phone:      String
  timezone:   String

schema = new Schema
  name:       String
  url:        String
  about:      String
  contacts:   [Contact]

module.exports = mongoose.model 'Company', schema