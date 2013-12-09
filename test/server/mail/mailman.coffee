{sinon, expect} = require '../test-lib-setup'
{data}          = require '../test-app-setup'

mailman         = require '../../../lib/mail/mailman'
util            = require '../../../app/scripts/util'

describe "mailman", ->
  # @testNum = 0

  # before dbConnect
  # after (done) -> dbDestroy @, done
  # beforeEach () ->
  #   @testNum++

  it "importantRequestEvent sends to options.owner + '@airpair.com'", (done) ->
    expect(mailman).to.be.a 'object'

    user = data.users[3]
    request = data.requests[7] # owner is mi
    sendMock = sinon.stub mailman, 'sendEmail', (opts, cb) -> cb()

    callback = (e) ->
      if e then return done e

      expect(sendMock.args[0][0].to).to.equal 'mi@airpair.com'
      expect(sendMock.calledOnce).to.equal true
      sendMock.restore()
      done()
    mailman.importantRequestEvent "evtName", user, request, callback

  it "should correctly render emails for important events", (done) ->
    user = data.users[5] # artjumble is an expert on request 7
    request = data.requests[7] # owner is mi
    # console.log user

    o =
      evtName: 'expert updated'
      user: user.google.displayName
      owner: request.owner # e.g. 'mi'
      requestId: "TESTID"
      customerName: request.company.contacts[0].fullName
      tags: request.tags
      tagsString: util.tagsString(request.tags)
      suggested: request.suggested

    o.templateName = 'importantRequestEvent'
    o.to = "#{o.owner}@airpair.com"
    o.subject =
      "[#{o.owner}] #{o.user} [#{o.evtName}] #{o.tagsString} request by #{o.customerName}"

    mailman.renderEmail o, 'importantRequestEvent', (e, rendered) ->
      if e then return done e
      rendered.Subject = o.subject
      text = "Steve Mathews [expert updated] tdd request by Jonathon Kresner\n\nhttps://www.airpair.com/adm/inbound/request/TESTID\n\n\n\n  Steve Mathews: waiting\n\n"
      html = "Steve Mathews [expert updated] tdd request by Jonathon Kresner\n\n<p>https://www.airpair.com/adm/inbound/request/TESTID</p>\n\n<p>\n\n  Steve Mathews: waiting<br />\n\n</p>\n"
      expect(rendered.Text).to.equal text
      expect(rendered.Html).to.equal html
      expect(rendered.Subject).to.equal '[mi] Steve Mathews [expert updated] tdd request by Jonathon Kresner'
      done()

  it "should NOT send importantRequestEvent email if the request has no owner", ->
    request = data.requests[2] # no owner field
    request.user = data.users[3]
    sendMailMock = sinon.stub mailman, 'sendEmail', (opts, cb) ->
      throw new Error('sendEmail should not be called!')

    # callback happens in same tick b/c there is no owner
    mailman.importantRequestEvent "evtName", {}, {}, (e) ->
      sendMailMock.restore()
