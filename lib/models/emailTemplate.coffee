mongoose          = require 'mongoose'
Schema            = mongoose.Schema
{ObjectId, Mixed} = Schema.Types

schema = new Schema
  slug:            { required: true, type: String, index: { unique: true } }
  subject:         String
  html:            String
  text:            String
  updatedAt:       { type: Date, default: Date }

module.exports = mongoose.model 'EmailTemplate', schema
