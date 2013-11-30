{sinon, expect} = require './../test-lib-setup'
{data} = require './../test-app-setup'

mailman = require('./../../../lib/mail/mailman')

describe "mailman", ->
  # @testNum = 0

  # before dbConnect
  # after (done) -> dbDestroy @, done
  # beforeEach () ->
  #   @testNum++

  it "importantRequestEvent sends to options.owner + '@airpair.com'", (done) ->
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
    mailman.importantRequestEvent options, callback

  it "should correctly render emails for important events", (done) ->
    user = data.users[3]
    request = data.requests[7] # owner is mi
    # console.log user

    options = {
      owner: request.owner # e.g. 'mi'
      requestId: "TESTID"
      evtName: 'expert updated'
      user: user.google.displayName
      expertStatus: "thisisanexpertstatus"
    }
    options.templateName = 'importantRequestEvent'
    options.to = "#{options.owner}@airpair.com"
    options.subject = "[#{options.owner}] '#{options.evtName}' triggered by #{options.user}"

    mailman.renderEmail options, 'importantRequestEvent', (e, rendered) ->
      if e then return done e
      rendered.Subject = options.subject

      str = """Fabian Schmengler triggered a "expert updated" event on the following request:\n\nhttps://www.airpair.com/adm/inbound/request/TESTID\n\n\n  Expert status: thisisanexpertstatus\n\n"""
      expect(rendered.Text).to.equal str
      expect(rendered.Html).to.equal str
      expect(rendered.Subject).to.equal '[mi] \'expert updated\' triggered by Fabian Schmengler'
      done()

  it "should NOT send importantRequestEvent email if the request has no owner", ->
    request = data.requests[2] # no owner field
    request.user = data.users[3]
    sendMailMock = sinon.stub mailman, 'sendEmail', (opts, cb) ->
      throw new Error('sendEmail should not be called!')

    # callback happens in same tick b/c there is no owner
    mailman.importantRequestEvent {}, (e) ->
      sendMailMock.restore()
