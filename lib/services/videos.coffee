_ = require 'underscore'
google = require('./wrappers/google')()
inspect = require('util').inspect

class VideosService
  # TODO might want to rename this function
  list: (oldRecordings, recordings, cb) ->
    # TODO only get data for ones that have changed
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
    # TODO store less data in the DB
    google.videosList params, (err, data) ->
      if err then return cb err
      console.log 'vl', inspect(data, { depth: null })

      data.items.forEach (item) ->
        # Tricky: this is actually mutating the original recordings array.
        recordingMap[item.id].resource = item

      cb null, recordings

  # TODO write for use by the upcoming expert videos API
  # getByExpertId:

module.exports = new VideosService()
