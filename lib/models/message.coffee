mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId


schema = new Schema
  from:       { type: ObjectId, ref: 'User' }
  to:         { type: ObjectId, ref: 'User' }
  utc:        { type: Date, default: Date }
  body:       String


module.exports = mongoose.model 'Message', schema
