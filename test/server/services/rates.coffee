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

    r = svc.calcSuggestedRate request, expert

    expect(r.expert).to.equal 70
    expect(r.total).to.equal 90

  it "should account for private pricing when calculating the rate", ->
    expert = rate: 160
    request = pricing: 'private', budget: 90

    r = svc.calcSuggestedRate request, expert

    expect(r.expert).to.equal 50
    expect(r.total).to.equal 90

  it "should split extra when expertRate < budget", ->
    expert = rate: 40
    request = pricing: 'opensource', budget: 90

    r = svc.calcSuggestedRate request, expert

    expect(r.expert).to.equal 49 #+9
    expect(r.total).to.equal 78  #29 profit

  it "should get expertRate = expertBudget when matching", ->
    expert = rate: 70
    request = pricing: 'opensource', budget: 90

    r = svc.calcSuggestedRate request, expert

    expect(r.expert).to.equal 70
    expect(r.total).to.equal 90