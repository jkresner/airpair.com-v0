mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

Contact = new Schema
  userId:     { type: ObjectId, index: true }
  pic:        String
  fullName:   String
  email:      { type: ObjectId, index: true }
  gmail:      String
  title:      String
  phone:      String
  twitter:    String
  timezone:   String
#  location:   String ( could be used to calculate timezone... )

schema = new Schema
  name:       { type: String, index: true }
  url:        String
  about:      String
  contacts:   [Contact]

module.exports = mongoose.model 'Company', schema