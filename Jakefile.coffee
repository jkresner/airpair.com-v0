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
      , (err) ->
        if err?
          console.log "Error", err
        else
          console.log "Success", recordsUpdated, "records updated"

