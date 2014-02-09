google = require('./wrappers/google2')
async = require 'async'

###
Some old videos to help test this:
- jkresner at gmail.com:
  http://www.youtube.com/watch?v=yc3NmCuOnpQ
- jk at airpair.com
  http://www.youtube.com/watch?v=OyFNWeQbe-0
###

class VideosService
  # first tries to fetch from team@ account, falls back to experts@ accounts
  fetch: (youtubeId, cb) =>
    params = id: youtubeId

    accounts = [
      'team@airpair.com', 'experts@airpair.com', 'jk@airpair.com', 'jkresner@gmail.com'
    ]
    message = "Not Found on #{accounts.join(', ')} accounts."

    google.videosList accounts.shift(), params, (err, data) =>
      video = found(err, data)
      if video then return cb null, video

      google.videosList accounts.shift(), params, (err, data) =>
        video = found(err, data)
        if video then return cb null, video

        google.videosList accounts.shift(), params, (err, data) =>
          video = found(err, data)
          if video then return cb null, video

          google.videosList accounts.shift(), params, (err, data) =>
            video = found(err, data)
            if video then return cb null, video
            return callback new Error message

    found: (err, data) ->
      forbidden = err && err.message.indexOf('Forbidden') == 0
      if forbidden then return false

      videoData = _.find data.items, (item) -> item.id == youtubeId
      if !videoData then return false
      videoData

  # TODO write for use by the upcoming expert videos API
  # getByExpertId:

module.exports = new VideosService()
