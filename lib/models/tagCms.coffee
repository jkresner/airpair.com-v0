mongoose = require 'mongoose'
Schema = mongoose.Schema
{ObjectId, Mixed} = Schema.Types

## Extra content for tag specific landing page

schema = new Schema
  tagId:  { type: ObjectId, ref: 'Tag' }
  codeReview:       { type: {} }
  pairProgramming:  { type: {} }
  problemSolving:   { type: {} }
  mentoring:        { type: {} }


module.exports = mongoose.model 'TagCms', schema