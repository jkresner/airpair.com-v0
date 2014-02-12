User         = require './../models/user'
bootUsers    = require('./users')   # create tags
bootTags     = require('./tags')   # create tags
bootExperts  = require('./experts')   # create tags
bootRequests = require('./requests')   # create tags


module.exports = ->

  if cfg.env.mode isnt 'test'
    bootUsers (users) ->
      bootTags (tags) ->
        bootExperts tags, (experts) ->
          bootRequests tags, experts, users, (requests) ->
            $log 'bootstrap complete'
  else
    bootTags (tags) ->
      $log 'test bootstrap complete'
