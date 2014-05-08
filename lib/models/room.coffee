mongoose = require 'mongoose'
Schema   = mongoose.Schema
{ObjectId, Mixed} = Schema.Types


room_status = ['active', 'archived', 'deleted']


RoomSchema = new Schema
  hipChatId:          { required: true, type: String }
  name:               { required: true, type: String }
  companyId:          { required: true, type: ObjectId, ref: 'Company', index: true }
  suggestionIds:      []
  members:            [{}]
  status:             { required: true, type: String, enum: room_status }
  history:            {}
  owner:              { required: true, type: String }


module.exports = mongoose.model 'Room', RoomSchema
