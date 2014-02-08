mongoose = require 'mongoose'
Schema = mongoose.Schema
{Mixed} = Schema.Types

schema = new Schema
  # unique of the API
  name:    { required: true, type: String } #  googleapi

  # some unique way to identify this user of this API
  user: { required: true, type: String } # team@airpair.com

  # Use this when we stop using google APIs
  # version: { type: String }
  data:    { required: true, type: Mixed  }
    # discover: { 'calendar': 'v3', 'youtube, 'v3' }
    # tokens
    #   access_token: 'fdggggfff'
    #   refresh_token: 'dsgs'

module.exports = mongoose.model 'ApiConfig', schema
