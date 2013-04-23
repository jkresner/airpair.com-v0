User = require './../models/user'
bootUsers = require('./users')   # create tags
bootTags = require('./tags')   # create tags
bootExperts = require('./experts')   # create tags
bootRequests = require('./requests')   # create tags


module.exports = ->

  bootUsers (users) ->
    bootTags (tags) ->
      bootExperts tags, (experts) ->
        bootRequests tags, experts, users, (requests) ->
          $log 'bootstrap complete'