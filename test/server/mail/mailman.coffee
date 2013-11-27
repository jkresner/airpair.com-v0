{sinon, expect} = require './../test-lib-setup'
{data} = require './../test-app-setup'

mailman = require('./../../../lib/mail/mailman')

describe "mailman", ->
  # @testNum = 0

  # before dbConnect
  # after (done) -> dbDestroy @, done
  # beforeEach () ->
  #   @testNum++

  it "sendEmailToOwner sends to options.owner + '@airpair.com'", (done) ->
    expect(mailman).to.be.a 'object'

    user = data.users[3]
    request = data.requests[3]
    sendMock = sinon.stub mailman, 'sendEmail', (opts) -> opts.callback()

    options = { owner: 'dt' }
    callback = (e) ->
      if e then return done e

      expect(sendMock.args[0][0].to).to.equal 'dt@airpair.com'
      expect(sendMock.calledOnce).to.equal true
      sendMock.restore()
      done()
    mailman.sendEmailToOwner options, callback
