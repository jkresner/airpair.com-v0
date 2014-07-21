{http,_,sinon,chai,expect,Factory} = require './../test-lib-setup'
{app, data} = require './../test-app-setup'
async = require 'async'

AutoMatcher = require('./../../../lib/services/AutoMatcher')

describe "AutoMatcher", ->
  describe "constructor(request)", ->
    # it "should set its request properly", (done) ->
    #   Factory.create 'rails-request', (request) ->
    #     new AutoMatcher request, (autoMatch) ->
    #       expect(autoMatch.requestId).to.equal(request.id)
    #       done()

    it "should yield a failed AutoMatch record if no experts available", (done) ->
      Factory.create 'rails-request', (request) ->
        new AutoMatcher request, (autoMatch) ->
          expect(autoMatch.status).to.equal('failed')
          done()

    it "picks at least one expert that matches", (done) ->
      async.series [
        (cb) -> Factory.create 'rails-request', (@request) -> cb()
        (cb) -> Factory.create 'dhh', (@dhh) -> cb()
        (cb) -> Factory.create 'aslak', -> cb()
      ], ->

        new AutoMatcher @request, (autoMatch) =>
          expect(autoMatch.experts.length).to.equal(1)
          expect(autoMatch.experts[0].email).to.equal(@dhh.email)
          done()
