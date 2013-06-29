{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'

RatesService = require('./../../../lib/services/rates')
svc = new RatesService()

describe "RatesService", ->
  @testNum = 0

  before ->
  after ->
  beforeEach -> @testNum++

  it "should get suggestedExpertRate < expertRate when expertRate > budget", ->
    expert = rate: 160
    request = pricing: 'opensource', budget: 90

    r = svc.calcSuggestedRates request, expert
    expect(r.opensource.expert).to.equal 70
    expect(r.opensource.total).to.equal 90
    expect(r.private.expert).to.equal 70
    expect(r.private.total).to.equal 110
    expect(r.nda.expert).to.equal 90
    expect(r.nda.total).to.equal 160

  it "should account for private pricing when calculating the rate", ->
    expert = rate: 160
    request = pricing: 'private', budget: 90

    r = svc.calcSuggestedRates request, expert

    expect(r.opensource.expert).to.equal 50
    expect(r.opensource.total).to.equal 70
    expect(r.private.expert).to.equal 50
    expect(r.private.total).to.equal 90
    expect(r.nda.expert).to.equal 70
    expect(r.nda.total).to.equal 140


  it "should split extra when expertRate < budget", ->
    expert = rate: 40
    request = pricing: 'opensource', budget: 90

    r = svc.calcSuggestedRates request, expert

    expect(r.opensource.expert).to.equal 49 #+9
    expect(r.opensource.total).to.equal 78  #29 profit
    expect(r.private.expert).to.equal 49 #+9
    expect(r.private.total).to.equal 98  #29 profit
    expect(r.nda.expert).to.equal 69 #+29
    expect(r.nda.total).to.equal 148  #29 profit

  it "should get expertRate = expertBudget when matching", ->
    expert = rate: 70
    request = pricing: 'nda', budget: 160

    r = svc.calcSuggestedRates request, expert

    expect(r.opensource.expert).to.equal 70
    expect(r.opensource.total).to.equal 90
    expect(r.private.expert).to.equal 70
    expect(r.private.total).to.equal 110
    expect(r.nda.expert).to.equal 90
    expect(r.nda.total).to.equal 160