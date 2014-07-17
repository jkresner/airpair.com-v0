{http,_,sinon,chai,expect} = require '../test-lib-setup'
{app, data}                                    = require '../test-app-setup'

ObjectId = require('mongoose').Types.ObjectId

ExpertsService = require('./../../../lib/services/experts')
svc = new ExpertsService

describe 'ExpertsService', ->
  mvh = data.experts[8] # Matthew Van Horn
  mp = data.experts[9] # Michael Prins

  describe 'getBySubscriptions', ->

    it "returns experts subscribed to a particular tag and skill level", (done) ->
      svc.create mvh, (e,r) ->
        svc.getBySubscriptions "514825fa2a26ea0200000031", "advanced", (e, experts) ->
          userNames = _.pluck(experts,'username')
          expect(userNames).to.include mvh.username
          done()

    it "doesn't return experts not subscribed to a particular tag and skill level", (done) ->
      svc.create mp, (e,r) ->
        svc.getBySubscriptions "514825fa2a26ea0200000031", "advanced", (e, experts) ->
          userNames = _.pluck(experts,'username')
          expect(userNames).to.not.include mp.username
          done()

  describe 'getByTagsAndMaxRate', ->

    # todo: depends on previous examples to put experts in db, kinda nasty
    it "returns experts with tags and rate less than the max", (done) ->
      svc.getByTagsAndMaxRate ['ruby-on-rails'], 100, (e, experts) ->
        userNames = _.pluck(experts,'username')
        expect(userNames).to.include mvh.username
        expect(userNames).to.not.include mp.username
        done()
