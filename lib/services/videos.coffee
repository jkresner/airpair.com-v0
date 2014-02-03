google = require('./wrappers/google')
inspect = require('util').inspect
Request = require('../models/request')

class VideosService
  fetch: (youtubeId, cb) ->
    params = id: youtubeId
    # TODO store less data in the DB
    google.videosList params, (err, data) ->
      if err then return cb err
      videoData = _.find data.items, (item) -> item.id == youtubeId
      cb null, videoData || {}

  getByExpertId: (expertId, cb) ->
    query =
      'calls.expertId': expertId
    select =
      'tags': 1,
      'calls.recordings.youtubeId': 1,
      'calls.recordings.link': 1,
      'calls.recordings.resource': 1,
    Request.find query, select, (err, requests) ->
      if err then return cb err

      console.log 'found!', inspect(requests, { depth: null })

      recordings = []
      # jesus is our lord and savior
      for r in requests
        for c in r.calls
          for recording in c.recordings
            if recording?.resource?.status?.privacyStatus == 'public'
              recording.requestId = r._id
              recording.callId = c._id
              recording.expertId = expertId
              recording.tags = r.tags
              recording.resource = undefined
              recordings.push recording

      cb null, recordings

module.exports = new VideosService()
