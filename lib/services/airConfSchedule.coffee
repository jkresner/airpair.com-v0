class AirConfSchedule
  convert = (username, social, speaker) =>
    {username, slug, name, shortbio, fullbio, talktitle, talkdescription, talktags, level, gravatar, pdt, youtube} = speaker
    result = _.extend {u: username, slug: slug}, social
    result = _.extend result,
      utc: pdt
      n: name
      b: fullbio
      c: shortbio
      t: talktitle
      a: talkdescription
      l: level
      g: gravatar
      tags: talktags.split(' ')
      y: youtube

  import: (callback) ->
    restler.get(config.defaults.airconf.scheduleUrl)
      .on 'success', (data, response) ->
        workshops = _.map data.feed.entry, (speaker) ->
          cleanSpeaker = {}
          _.each _.keys(speaker), (key) ->
            cleanSpeaker[key.replace("gsx$", "")] = speaker[key].$t
          _.tap {}, (item)->
            social = {}
            social[cleanSpeaker.socialtype] = cleanSpeaker.socialid
            item[cleanSpeaker.username] = convert(cleanSpeaker.username, social, cleanSpeaker)
        callback(workshops)

module.exports = new AirConfSchedule()
