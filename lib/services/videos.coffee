_ = require 'underscore'
google = require('./wrappers/google')
inspect = require('util').inspect

class VideosService
  fetch: (youtubeId, cb) ->
    params = id: youtubeId
    # TODO store less data in the DB
    google.videosList params, (err, data) ->
      if err then return cb err
      videoData = _.find data.items, (item) -> item.id == youtubeId
      cb null, videoData || {}

  # TODO write for use by the upcoming expert videos API
  # getByExpertId:

module.exports = new VideosService()
