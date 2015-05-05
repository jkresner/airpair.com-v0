# mongoose = require 'mongoose'
# Schema   = mongoose.Schema
# ObjectId = Schema.ObjectId;

# Request = require './request'

# VALID_STATUSES = ['pending','completed', 'failed']

# AutoMatchSchema = new Schema
#   requestId: { required: true, type: ObjectId, ref: 'Request', index: true }
#   status: { required: true, type: String, index: true, enum: VALID_STATUSES, default: 'pending' }

# module.exports = mongoose.model 'AutoMatch', AutoMatchSchema
