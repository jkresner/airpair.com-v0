mongoose = require 'mongoose'
Schema = mongoose.Schema
# ObjectId = Schema.ObjectId;

schema = new Schema
  # thread: ObjectId
  # date: {type: Date, default: Date.now}
  # author: {type: String, default: 'Anon'}
  # name:     String
  # email:        email
  # rate:         rate
  # gh:           gh
  # so:           so
  # homepage:     homepage
  # pic:          pic
  # other:        other
  # skills:       skills

module.exports = mongoose.model 'Dev', schema