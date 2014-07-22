http = require 'supertest'
_    = require 'lodash'

# Creates a request and let's you run a test on it

module.exports = (app) ->
  (reqData, callback) ->
    newReq = _.clone reqData
    delete newReq._id
    http(app).post("/api/requests")
      .send(newReq)
      .expect(200)
      .end (e, r) =>
        if e then return callback e
        body = _.clone r.body
        callback null, body
