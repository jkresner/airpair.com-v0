namespace 'test', ->
  desc('Test runners')
  task 'server', (params) ->
    execString = 'mocha test/server/**/*Spec.coffee'
    execString += " -g \"#{params}\"" if params?
    console.log execString
    jake.createExec([execString])
      .addListener 'stdout', (message) ->
        process.stdout.write(message.toString())
      .addListener 'error', (message) ->
        process.stdout.write(message.toString())
      .run()

namespace 'db', ->
  desc('These are the database tasks')
  task 'reset', ->
    exec = require('child_process').exec
    exec 'echo "use airpair_dev\ndb.dropDatabase()" | mongo', (error, stdout, stderr) ->
      console.log(stdout)

  namespace 'test', ->
    task 'reset', ->
      exec = require('child_process').exec
      exec 'echo "use airpair_test\ndb.dropDatabase()" | mongo', (error, stdout, stderr) ->
        console.log(stdout)

namespace 'onetime', ->
  desc('one time scripts for data updates')
  task 'createAirconfWorkshops', {async: true},  ->
    require("./scripts/env")
    async = require("async")
    ViewData = require './lib/services/_viewdata.data'
    console.log "Creating workshops for airconf"

    recordsUpdated = 0
    async.each _.values(ViewData.workshops), (workshop, callback)->
      if workshop.slug?
        speaker =
          name: workshop.n
          shortBio: workshop.c
          fullBio: workshop.b
          username: workshop.u
          gravatar: workshop.g
          so: workshop.so
          tw: workshop.tw
          ln: workshop.ln
          gh: workshop.gh

        workshopData =
          slug: workshop.slug
          title: workshop.t
          description: workshop.a
          difficulty: workshop.l
          speakers: [speaker]
          time: workshop.utc
          attendees: []
          duration: "1 hour"
          price: 0
          tags: workshop.tags

        Workshop.find { slug: workshop.slug }, (err, requests) ->
          unless _.some(requests)
            new Workshop(workshopData).save (err, record) =>
              recordsUpdated++
              callback()
          else
            callback()
      else
        callback()
    , (err) ->
      if err?
        console.log "Error", err
      else
        console.log "Success", recordsUpdated, "records updated"
      complete()
