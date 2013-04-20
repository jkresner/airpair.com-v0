mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

Contact = new Schema
  userId:     ObjectId
  avatarUrl:  String
  fullName:   String
  email:      String
  gmail:      String
  title:      String
  phone:      String
  twitter:    String
  timezone:   String
#  location:   String ( could be used to calculate timezone... )

schema = new Schema
  name:       String
  url:        String
  about:      String
  contacts:   [Contact]

module.exports = mongoose.model 'Company', schema