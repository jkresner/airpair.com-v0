{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require '../test-lib-setup'
{app, data}                                    = require '../test-app-setup'

ObjectId = require('mongoose').Types.ObjectId

ExpertsService = require('./../../../lib/services/experts')
svc = new ExpertsService

describe 'ExpertsService', ->
  before dbConnect
  after (done) -> dbDestroy @, done

  it "returns experts subscribed to a particular tag and skill level", (done) ->
    mvh = data.experts[8] # Matthew Van Horn
    svc.create mvh, (e,r) ->
      svc.getBySubscriptions "514825fa2a26ea0200000031", "advanced", (e, experts) ->
        userNames = _.pluck(experts,'username')
        expect(userNames).to.include mvh.username
        done()

  it "doesn't return experts not subscribed to a particular tag and skill level", (done) ->
    mp = data.experts[9] # Michael Prins
    svc.create mp, (e,r) ->
      svc.getBySubscriptions "514825fa2a26ea0200000031", "advanced", (e, experts) ->
        userNames = _.pluck(experts,'username')
        expect(userNames).to.not.include mp.username
        done()
