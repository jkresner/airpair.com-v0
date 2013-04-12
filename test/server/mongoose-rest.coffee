mongoose = require 'mongoose'
assert = require("chai").assert

describe "REST update with mongoose", ->
  before (done) ->
    mongoose.connect "mongodb://localhost/airpair_test", done

  it "should change fields on a single document", (done) ->
    #create our test document, grab it's ID
    #call update with some params
    #verify the response
    #maybe reload from mongo and verify
    done()
