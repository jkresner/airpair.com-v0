mongoose = require 'mongoose'
assert = require("chai").assert

describe "REST update with mongoose", ->
	console.log("@bug describe running");
	before (done) ->
		console.log("@bug before is running");
		mongoose.connect "mongodb://localhost/airpair_test", (error) ->
			console.log("@bug connected to airpair_test");
			done error

	#connect to a test mongoDB "airpair-test"
  it "should change fields on a single document", (done) ->
  	console.log("@bug 'it' test running");
   #create our test document, grab it's ID
   #call update with some params
   #verify the response
   #maybe reload from mongo and verify
   done()
