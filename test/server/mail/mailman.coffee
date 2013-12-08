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
    user = data.users[5] # artjumble is an expert on request 7
    request = data.requests[7] # owner is mi
    # console.log user

    options =
      owner: request.owner # e.g. 'mi'
      requestId: "TESTID"
      evtName: 'expert updated'
      user: user.google.displayName
      expertStatus: "thisisanexpertstatus"
      customerName: request.company.contacts[0].fullName
      tags: request.tags
      suggested: request.suggested

    options.templateName = 'importantRequestEvent'
    options.to = "#{options.owner}@airpair.com"

    options.tagsString = util.tagsString(options.tags)
    {owner, evtName, customerName, user, tagsString} = options
    options.subject =
      "[#{owner}] #{user} [#{evtName}] #{tagsString} request by #{customerName}"

    mailman.renderEmail options, 'importantRequestEvent', (e, rendered) ->
      if e then return done e
      rendered.Subject = options.subject
      str = """Steve Mathews [expert updated] tdd request by Jonathon Kresner\n\nhttps://www.airpair.com/adm/inbound/request/TESTID\n\n  Steve Mathews: thisisanexpertstatus\n\n\nPreviously:\n\n  Steve Mathews: \n\n"""
      expect(rendered.Text).to.equal str
      expect(rendered.Html).to.equal str
      expect(rendered.Subject).to.equal '[mi] Steve Mathews [expert updated] tdd request by Jonathon Kresner'
      done()

  it "should NOT send importantRequestEvent email if the request has no owner", ->
    request = data.requests[2] # no owner field
    request.user = data.users[3]
    sendMailMock = sinon.stub mailman, 'sendEmail', (opts, cb) ->
      throw new Error('sendEmail should not be called!')

    # callback happens in same tick b/c there is no owner
    mailman.importantRequestEvent {}, (e) ->
      sendMailMock.restore()
