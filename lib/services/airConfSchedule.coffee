Workshop = require("../models/workshop")

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

  update: (callback) ->
    moment = require 'moment-timezone'
    async = require("async")
    console.log "Creating workshops for airconf"
    recordsUpdated = 0
    @import (workshops) ->
      async.each workshops, (workshopObject, asyncCallback) ->
        workshop = _.values(workshopObject)[0]
        if workshop.slug != ""
          speaker =
            name: workshop.n
            shortBio: workshop.c
            fullBio: workshop.b
            username: workshop.u
            gravatar: workshop.g
            bb: workshop.bb
            so: workshop.so
            tw: workshop.tw
            in: workshop.in
            gh: workshop.gh

          workshopData =
            slug: workshop.slug
            title: workshop.t
            description: workshop.a
            difficulty: workshop.l
            speakers: [speaker]
            time: moment.tz(workshop.utc, 'Etc/GMT+7').format()
            attendees: []
            duration: "1 hour"
            price: 0
            tags: workshop.tags
            youtube: workshop.y

          Workshop.findOne { slug: workshop.slug }, (err, existingWorkshop) ->
            recordsUpdated++
            if existingWorkshop?
              Workshop.update {_id: existingWorkshop.id}, workshopData, {}, (err, record) ->
                asyncCallback()
            else
              new Workshop(workshopData).save (err, record) =>
                asyncCallback()
        else
          asyncCallback()
      , (err) ->
        if err?
          console.log "Error", err
        else
          console.log "Success", recordsUpdated, "records updated"
        callback(null, {message: "Success: #{recordsUpdated} records updated."})

module.exports = new AirConfSchedule()
