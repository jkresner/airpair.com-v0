async = require("async")

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
    AirConfSchedule = require './lib/services/airConfSchedule'
    console.log "Creating workshops for airconf"
    AirConfSchedule.update(complete)

  task 'updateAirconfCredit', {async: true},  ->
    require("./scripts/env")
    OrdersService = require './lib/services/orders'
    ordersService = new OrdersService
    console.log "Updating airconf credit entries"
    recordsUpdated = 0
    ordersService.getByRequestId "53ce8a703441d602008095b6", (err, orders) ->
      async.each orders, (order, asyncCallback) ->
        unless order.paymentStatus == "paidout"
          lineItems = _.map order.lineItems, (lineItem) ->
            if lineItem.type == "credit" && lineItem.unitPrice == 0
              lineItem.unitPrice = -150
            lineItem
          recordsUpdated++
          ordersService.update order._id, {lineItems}, asyncCallback
        else
          asyncCallback()

  task 'addAvailabilityToExpert', {async: true},  ->
    require("./scripts/env")
    async = require("async")
    console.log "Adding availability to expert"
    recordsUpdated = 0
    Expert.find {}, (err, experts) ->
      async.each experts, (expert, callback)->
        unless expert.availability?
          recordsUpdated++
          expert.availability = ""
          expert.save(callback)
        else
          callback(null, expert)
      , (err) ->
        if err?
          console.log "Error", err
        else
          console.log "Success", recordsUpdated, "records updated"
        complete()

  task 'addUpdatedAtToExpert', {async: true},  ->
    require("./scripts/env")
    ObjectId2Date = require("./lib/mix/objectId2Date")
    async = require("async")
    console.log "Adding updatedAt to expert"
    recordsUpdated = 0
    Expert.find {}, (err, experts) ->
      async.each experts, (expert, callback)->
        recordsUpdated++
        expert.updatedAt = ObjectId2Date(expert._id)
        expert.save(callback)
      , (err) ->
        if err?
          console.log "Error", err
        else
          console.log "Success", recordsUpdated, "records updated"
        complete()

  task 'addMinRateToExpert', {async: true},  ->
    require("./scripts/env")
    async = require("async")
    console.log "Adding minRate to expert"
    recordsUpdated = 0
    values = [10, 40, 70, 110, 160, 230]
    Expert.find {}, (err, experts) ->
      async.each experts, (expert, callback)->
        if !expert.minRate? && expert.rate?
          recordsUpdated++
          index = values.indexOf(expert.rate)
          index-- if expert.rate > 10
          index = 5 if expert.rate > 230
          expert.minRate = values[index]
          expert.minRate = 0 if !expert.minRate?
          expert.save(callback)
        else
          callback(null, expert)
      , (err) ->
        if err?
          console.log "Error", err
        else
          console.log "Success", recordsUpdated, "records updated"
        complete()

  task 'addLevelsToExpertTags', {async: true},  ->
    require("./scripts/env")
    async = require("async")
    console.log "Adding levels to expert tags"
    recordsUpdated = 0
    Expert.find {}, (err, experts) ->
      async.each experts, (expert, callback)->
        recordsUpdated++
        tags = _.map expert.tags, (tag) ->
          newTag = _.clone(tag)
          newTag.levels = ['beginner', 'intermediate', 'expert']
          newTag
        expert.tags = tags
        expert.save(callback)
      , (err) ->
        if err?
          console.log "Error", err
        else
          console.log "Success", recordsUpdated, "records updated"
        complete()
