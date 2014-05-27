google = require('./wrappers/google')

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

  # TODO write for use by the upcoming expert videos API
  # getByExpertId:

module.exports = VideosService
