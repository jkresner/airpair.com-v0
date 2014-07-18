{http, _, sinon, chai, expect} = require './../test-lib-setup'
{app, data, passportMock} = require './../test-app-setup'

require('./../../../lib/api/session')(app)

describe "REST api companys", ->

  it "returns a simple session if not authenticated", (done) ->
    passportMock.setSession 'anon'
    http(app).get('/api/session')
      .expect(200)
      .end (err, res) =>
        body = res.body
        expect(body.user.authenticated).to.be.false
        expect(body.config.segmentioKey?).to.be.true
        done()

  it "returns a the full session with user if logged in", (done) ->
    passportMock.setSession 'jk'
    http(app).get('/api/session')
      .expect(200)
      .end (err, res) =>
        body = res.body
        expect(body.user._id?).to.be.true
        expect(body.config.segmentioKey?).to.be.true
        done()
