{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app,data,passportMock}                        = require './../test-app-setup'

require('./../../../lib/api/requests')(app)
require('./../../../lib/api/orders')(app)

createReq = require('../util/createRequest')(app)


describe "REST api orders", ->
  @testNum = 0
  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach -> @testNum++

  it "can not create order if not authenticated", (done) ->
    passportMock.setSession 'anon'
    order = data.orders[1]
    http(app).post('/api/orders/')
      .set('Accept', 'application/json')
      .send(order)
      .expect(403)
      .expect({})
      .end done

  it "creates order if authenticated", (done) ->
    @timeout 10000
    passportMock.setSession 'bchristie'

    order = data.orders[1]
    bchristieReq = data.requests[10]

    createReq bchristieReq, (e, req) =>
      if e then return done e
      order.requestId = req._id
      http(app).post('/api/orders/')
        .set('Accept', 'application/json')
        .send(order)
        .expect(200)
        .end (err, res) =>
          d = res.body
          expect(d)
          expect(d.paymentStatus).to.equal 'received'
          expect(d.profit).to.equal 40
          expect(d.total).to.equal 180
          done()
