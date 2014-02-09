google = require('./wrappers/google')

###
Some old videos to help test this:

- team at airpair:
  https://www.youtube.com/watch?v=qhpIA4O1jx4

- experts at airpair:
  http://www.youtube.com/watch?v=dA23bgwhDAE

- jk at airpair.com
  http://www.youtube.com/watch?v=OyFNWeQbe-0

- jkresner at gmail.com:
  http://www.youtube.com/watch?v=yc3NmCuOnpQ
###

class VideosService
  # tries to fetch a video from each account, falling back to the next if the
  # video was not found
  fetch: (youtubeId, cb) =>
    params = id: youtubeId

    accounts = [
      'team@airpair.com', 'experts@airpair.com', 'jk@airpair.com', 'jkresner@gmail.com'
    ]
    message = "Not Found on #{accounts.join(', ')} accounts."

    google.videosList accounts[0], params, (err, data) =>
      video = getVideo(err, data)
      if video then return cb null, video

      google.videosList accounts[1], params, (err, data) =>
        video = getVideo(err, data)
        if video then return cb null, video

        google.videosList accounts[2], params, (err, data) =>
          video = getVideo(err, data)
          if video then return cb null, video

          google.videosList accounts[3], params, (err, data) =>
            video = getVideo(err, data)
            if video then return cb null, video
            return cb new Error message

    getVideo = (err, data) ->
      forbidden = err && err.message.indexOf('Forbidden') == 0
      if forbidden then return false
      _.find data.items, (item) -> item.id == youtubeId

  # TODO write for use by the upcoming expert videos API
  # getByExpertId:

module.exports = new VideosService()
