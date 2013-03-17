mongoose = require 'mongoose'
Schema = mongoose.Schema


"""
Request status

  received      : requires review by airpair
  incomplete    : more detail required
  review        : company must choose one or more developers
  scheduled     : one or more airpairs scheduled
  completed     : feedback on all calls collected
  canceled      : company has canceled the request

  after a user saves info from incomplete state, request goes back into received

Suggestion status

  unconfirmed   : contacted the developer about availability & relevance
  passed        : if developer is not available or
  available     : developer would like to take the call
  booked        : developer has been booked for an airpair

"""


Event = new Schema
  occurred:         Date
  name:             String


Skill = new Schema
  _id:              String
  shortName:        Date


Suggestion = new Schema
  status:           String
  events:           [Event]
  dev:              { {}, required: true }
  availability:     [Date]
  comment:          String


Call = new Schema
  dev:              { {}, required: true }
  time:             Date
  recordingUrls:    []
  type:             String        # opensource, private, subscription
  devRate:          Number
  fee:              Number
  review:           String
  devEndorsed:      String


schema = new Schema
  events:           [Event]       # created, updated, reviewed,
  status:           String    # received
  by:
    _id:            { type: ObjectId , required: true }
    name:           { type: String, required: true }
    about:          { type: String, required: true }
    contacts:       { type: [], required: true }
  availability:     [Date]
  breif:            String
  skills:           [Skill]
  suggested:        [Suggestion]
  calls:            [Call]
  canceledReason:   String


module.exports = mongoose.model 'Request', schema