google = require('./wrappers/google')
Expert = require('../models/expert')
Request = require('../models/request')

inspect = require('util').inspect

class VideosService
  # tries to fetch a video from each account, falling back to the next if the
  # video was not found
  fetchYouTube: (youtubeId, cb) =>
    params = id: youtubeId

    accounts = [
      'team@airpair.com', 'experts@airpair.com', 'jk@airpair.com', 'jkresner@gmail.com'
    ]
    message = "Not Found on #{accounts.join(', ')} accounts."

    google.videosList accounts[0], params, (err, data) =>
      video = handleYouTube(err, data)
      if video then return cb null, video

      google.videosList accounts[1], params, (err, data) =>
        video = handleYouTube(err, data)
        if video then return cb null, video

        google.videosList accounts[2], params, (err, data) =>
          video = handleYouTube(err, data)
          if video then return cb null, video

          google.videosList accounts[3], params, (err, data) =>
            video = handleYouTube(err, data)
            if video then return cb null, video
            return cb new Error message

    handleYouTube = (err, data) ->
      forbidden = err && err.message.indexOf('Forbidden') == 0
      if forbidden then return false
      _.find data.items, (item) -> item.id == youtubeId

  getBySoId: (soId, cb) ->
    # TODO we should be storing these as strings in mongo, not ints.
    soId = parseInt(soId, 10)
    if isNaN(soId) then return cb new Error 'Not a valid ID'

    query =
      'so.id': soId
    console.log 'q', query
    Expert.findOne(query).lean().exec (err, expert) =>
      if err then return cb err
      if !expert then return cb null, { message: 'Something went wrong' }
      console.log 'e', expert
      expertId = expert._id
      query =
        'calls.expertId': expertId
      select =
        'tags.name': 1
        'calls._id': 1
        'calls.recordings.data.id': 1
        'calls.recordings.data.snippet.publishedAt': 1
        'calls.recordings.data.snippet.channelId': 1
        'calls.recordings.data.snippet.title': 1
        'calls.recordings.data.snippet.description': 1
        'calls.recordings.data.snippet.channelTitle': 1
        'calls.recordings.data.status.privacyStatus': 1

      Request.find(query, select).lean().exec (err, requests) ->
        if err then return cb err

        console.log 'found!', inspect(requests, { depth: null })
        calls = _.pluck(requests, 'calls')
        recordings = _.pluck(_.flatten(calls), 'recordings')
        console.log 'found!', inspect(recordings, { depth: null })

        recordings = []
        # jesus is our lord and savior
        for r in requests
          for c in r.calls
            for recording in c.recordings
              if recording?.data?.status?.privacyStatus == 'public'
                recording.requestId = r._id
                recording.callId = c._id
                recording.expertId = expertId
                recording.tags = r.tags
                recording.data.status = undefined
                console.log _.keys(r), recording
                # recording.data = undefined
                recordings.push recording
        response =
          name: expert.name
          rate: expert.rate
          so: expert.so
          recordings: recordings
          email: expert.email
          brief: expert.brief
          gh: expert.gh
          tags: expert.tags
          # twitter?

        cb null, response

module.exports = new VideosService()
