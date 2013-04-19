mongoose = require 'mongoose'
assert = require("chai").assert

describe "Can sign in with 3rd parties", ->

  before (done) ->
    mongoose.connect "mongodb://localhost/airpair_test", done

  it "Can sign in with github as new user", (done) ->
    done()

  it "Can sign in with google as new user", (done) ->
    done()

  it "Can sign in with github as existing github user", (done) ->
    done()

  it "Can sign in with google as existing github user", (done) ->
    done()

  it "Can sign in with github as existing google user", (done) ->
    done()