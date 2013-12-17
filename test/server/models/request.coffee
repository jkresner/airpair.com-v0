{http,_,sinon,chai,expect,dbConnect,dbDestroy} = require './../test-lib-setup'
{app,data,passportMock} = require './../test-app-setup'
ObjectId = require('mongoose').Types.ObjectId
Request = require('lib/models/request')

VALID_REQUEST = {
  availability: "SFO",
  brief: "I need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen. I need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen.",
  budget: 90,
  canceledDetail: "",
  owner: "mi",
  company: {
    "_id": "5181ed3e312c520200000004",
    "contacts": [
      {
        "fullName": "Jonathon Kresner", "email": "jk@airpair.com", "gmail": "jk@airpair.com",
        "userId": "5175efbfa3802cc4d5a5e6ed", "pic": "https://lh3.googleusercontent.com/-NKYL9eK5Gis/AAAAAAAAAAI/AAAAAAAAABY/291KLuvT0iI/photo.jpg",
        "twitter": "jkresner", "timezone": "GMT-0700 (PDT)", "_id": "51b259ac22ddda020000000b"
      }
    ],
    about: "We help companies find real time software help!\n\nType in the technologies you use and we will find you what you need!\n\nIt's an awesome service you should tyr it!",
    name: "airpair, inc.",
    url: "www.airpair.com",
  },
  owner: 'mi'
  hours: "1",
  pricing: "opensource",
  status: "review",
  userId: "5175efbfa3802cc4d5a5e6ed",
  calls: [],
  suggested: [
    {
      expert: {
        "tags": [],
        "username": "artjumble",
        "userId": "51828a1066a6f999a465f292",
        "timezone": "GMT-0700 (MST)",
        "status": "waiting",
        "rate": 70,
        "pic": "https://secure.gravatar.com/avatar/0a2cb1e3af6082a7dc8d6200d237299f",
        "other": "",
        "name": "Steve Mathews",
        "in": { "displayName": "Steve Mathews", "id": "VZovK2UHph" }
        "hours": "2",
        "homepage": "artjumble.com/blog",
        "gmail": "happydog@gmail.com",
        "gh": {
          "followers": 0,
          "gravatar_id": "0a2cb1e3af6082a7dc8d6200d237299f",
          "blog": "artjumble.com/blog",
          "location": "Phx, AZ",
          "username": "artjumble",
          "id": 125826
        },
        "email": "happydog@gmail.com",
        "brief": "Helping new developers learn, or get started with a new technology.",
        "_id": "514a38d9bf8213020000000b"
      },
      suggestedRate: { opensource: { expert: 70, total: 90 }, private: { expert: 70, total: 110 }, nda: { expert: 70, total: 160 } },
      expertStatus: "waiting",
      _id: "51b25a1722ddda020000000d",
      events: []
    }
  ],
  events: [{}],
  tags: []
}

describe "requestCalls REST API", ->
  @testNum = 0

  before dbConnect
  after (done) -> dbDestroy @, done
  beforeEach -> @testNum++

  it "request.calls should be a list of call subdocs", (done) ->
    expertId1 = new ObjectId
    request = new Request VALID_REQUEST
    request.calls.push
      expertId: expertId1
      type: 'opensource'
    request.save (error, request2) ->
      expect(error).to.be.null
      expect(request2).to.exist
      expect(request2.calls).to.have.length(1)
      expect(request2.calls[0].type).to.equal('opensource')
      expect(request2.calls[0].expertId.equals(expertId1)).to.be.true
      done()

  it "request.calls.type should enforce valid type values", (done) ->
    expertId1 = new ObjectId
    request = new Request VALID_REQUEST
    request.calls.push
      expertId: expertId1
      type: 'thisisaninvalidcalltype'
    request.validate (error) ->
      expect(error).to.exist
      expect(error.name).to.equal('ValidationError')
      done()
