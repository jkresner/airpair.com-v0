User = require './../models/user'
bootTags = require('./tags')   # create tags
# bootExperts = require('./experts')   # create tags


module.exports = ->


  User.find({}).remove()

  bootTags ->
  # bootTags bootExperts
