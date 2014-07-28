{http,_,sinon,chai,expect,Factory} = require './../test-lib-setup'
{app, data} = require './../test-app-setup'
async = require 'async'

AutoMatcher = require('./../../../lib/services/AutoMatcher')

describe "AutoMatcher", ->
  describe "notifyExperts(request)", ->
    before (done) ->
      async.parallel [
        (cb) => Factory.create 'rails-request', (@request) => cb()
        (cb) => Factory.create 'dhhExpert', (@dhh) => cb()
        (cb) => Factory.create 'aslakExpert', (@aslak) => cb()
      ], =>
        @autoMatcher = new AutoMatcher()
        done()

    it "should yield a failed AutoMatch record if no experts available", (done) ->
      @autoMatcher.expertService = # stub
        getByTagsAndMaxRate: (soTagIds, maxRate, cb) => cb(null, [])
      @autoMatcher.notifyExperts @request, (err, autoMatch) ->
        expect(autoMatch.status).to.equal('failed')
        done()

    it "notifies the expert that matches", (done) ->
      @autoMatcher.expertService = # stub
        getByTagsAndMaxRate: (soTagIds, maxRate, cb) =>
          cb null, [@dhh]

      mailMock = sinon.mock(@autoMatcher.mailmanService)
      mailMock.expects('sendAutoNotification').once().withExactArgs(@dhh, @request)

      @autoMatcher.notifyExperts @request, (err, autoMatch) =>
        mailMock.verify()
        done()

    it "returns a completed AutoMatch object with matched experts", (done) ->
      @autoMatcher.expertService = # stub
        getByTagsAndMaxRate: (soTagIds, maxRate, cb) =>
          cb null, [@dhh]

      @autoMatcher.notifyExperts @request, (err, autoMatch) =>
        expect(autoMatch.experts.length).to.equal(1)
        expect(autoMatch.experts[0].email).to.equal(@dhh.email)
        expect(autoMatch.status).to.equal('completed')
        done()

