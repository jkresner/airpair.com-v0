# mongoose = require 'mongoose'
# Schema   = mongoose.Schema
# {Mixed}  = Schema.Types

# schema = new Schema
#   # unique name of the API
#   name:    { required: true, type: String } # e.g. googleapi

#   # some unique way to identify this user of this API
#   user: { required: true, type: String } # e.g. team@airpair.com

#   # Use this for other non-google apis
#   # version: { type: String }
#   data:    { required: true, type: Mixed  }
#     # discover: { 'calendar': 'v3', 'youtube, 'v3' }
#     # tokens:
#     #   access_token: 'some-access-token'
#     #   refresh_token: 'some-refresh-token'

# module.exports = mongoose.model 'ApiConfig', schema
