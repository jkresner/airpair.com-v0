mongoose          = require 'mongoose'
Schema            = mongoose.Schema
{ObjectId, Mixed} = Schema.Types


PayMethod = new Schema
  type:            { required: true, type: String }
  info:            { required: true, type: {} }
  sharers:         [{}]


module.exports = mongoose.model 'PayMethod', PayMethod
