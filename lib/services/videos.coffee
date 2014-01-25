_ = require 'underscore'
google = require('./wrappers/google')()
inspect = require('util').inspect

# TODO stop using mutation to assign back to the original array.
# it's confusing.
class VideosService
  # TODO might want to rename this function
  list: (recordings, cb) ->
    # TODO remove this stuff when requestCalls is simplified
    if !recordings.length
      return process.nextTick ->
        cb null, recordings

    # TODO if the same youtube ID is in the list twice, only one of the
    # recordings objects will get the youtube resource data.
    recordingMap = {}
    youtubeIds = []
    for recording in recordings
      recordingMap[recording.youtubeId] = recording
      youtubeIds.push recording.youtubeId

    params = id: youtubeIds.join(',')
    # TODO will only fetch data for the first 50 videoIds
    google.videosList params, (err, data) ->
      if err then return cb err
      console.log 'vl', inspect(data, { depth: null })

      data.items.forEach (item) ->
        # TODO store less data in the DB
        recordingMap[item.id].resource = item

      cb null, recordings

  # TODO write for use by the upcoming expert videos API
  # getByExpertId:

module.exports = new VideosService()
