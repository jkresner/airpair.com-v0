mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

Contact = new Schema
  userId:     ObjectId
  fullName:   String
  email:      String
  gmail:      String
  title:      String
  phone:      String
  timezone:   String

schema = new Schema
  name:       String
  url:        String
  about:      String
  contacts:   [Contact]

module.exports = mongoose.model 'Company', schema