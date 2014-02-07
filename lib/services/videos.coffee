google = require('./wrappers/google')

team = google.team
experts = google.experts

class VideosService
  # first tries to fetch from team@ account, falls back to experts@ accounts
  fetch: (youtubeId, cb) =>
    params = id: youtubeId
    team.videosList params, (err, data) =>
      if err && err.message.indexOf('Forbidden') == 0
        return @fetchExperts(youtubeId, cb)

      videoData = _.find data.items, (item) -> item.id == youtubeId
      if !videoData
        return @fetchExperts(youtubeId, cb)

      @respond(err, youtubeId, data, cb)

  fetchExperts: (youtubeId, cb) =>
    console.log 'fetchExperts', youtubeId
    params = id: youtubeId
    experts.videosList params, (err, data) =>
      @respond(err, youtubeId, data, cb)

  respond: (err, youtubeId, data, cb) =>
    if err then return cb err
    videoData = _.find data.items, (item) -> item.id == youtubeId
    message = 'Not Found on team@ nor experts@ accounts.'
    if !videoData then return cb new Error message
    cb null, videoData

  # TODO write for use by the upcoming expert videos API
  # getByExpertId:

module.exports = new VideosService()
