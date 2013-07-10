module.exports = [

  # 0) Not used
  {},

  # 1) Used in test 1 in /server/api/requests
  {
    "company":{"_id":"517086de5f2b59376c000006","contacts":[{"fullName":"Jonathon Kresner","email":"jk@airpair.com","gmail":"jk@airpair.com","title":"","phone":"","userId":"517085a61dd90b04cddccc9d","avatarUrl":"https://lh3.googleusercontent.com/-NKYL9eK5Gis/AAAAAAAAAAI/AAAAAAAAABY/291KLuvT0iI/photo.jpg","twitter":"hackerprenuer","timezone":"GMT+1000 (EST)","_id":"517086de5f2b59376c000007"}],"name":"airpair, inc.","url":"airpair.com","about":"We connect entrepreneurs with developers","__v":0},"tags":[{"_id":"516f3dfb1dd90b04cddccc93","name":"c","short":"c","soId":"c"},{"_id":"516f77f81dd90b04cddccc98","name":"c++","short":"c++","soId":"c++"}],
    "availability":"2013-04-23T14:00:09.000Z",
    "hours":"1",
    "budget":90,
    "pricing":"opensource",
    "brief":"api/requests test 1) !"
  }

  # 2) Used in test server/bootstrap/requests
  {
    _id: "515a60284bfa2f0200000052",
    brief: 'At various times I need help with Objective-C for iOS.',
    canceledReason: '',
    company:
      contacts: [ {} ]
      about: 'We like to test airpair.com in a way that makes our systems safe, secure, fast and beautiful.\n\nWe approach testing as a trade off more than pure TDD. JavaScript is an amazing language, but is kind of dangerous so test coverage is important, but not at the expense of speed to market.\n\nSinon is a great framework and brunch comes with mocha-phantom support.'
      url: 'testing.airpair.com'
      name: 'Test Co.'
    budget: 50,
    hours: '1',
    pricing: 'opensource',
    status: 'review',
    calls: [],
    suggested:
      [
        {
          status: 'awaiting'
          comment: ''
          expert:
            "_id":"5173116b1dd90b04cddccce4",
            "userId":"5173116b1dd90b04cddccce4",
            "name":"Jonathon Kresner",
            "email":"jk@airpair.com",
            "gmail":"jk@airpair.com",
            "username":"jkresner",
            "homepage":"http://www.hackperneurialism.com",
            "pic":"https://lh3.googleusercontent.com/-NKYL9eK5Gis/AAAAAAAAAAI/AAAAAAAAABY/291KLuvT0iI/photo.jpg",
            "timezone":"GMT+1000 (EST)",
            "in":{"id":"d9YFKgZ7rY","displayName":"Jonathon Kresner"},
            "tw":{"id":21989578,"username":"hackerpreneur"},
            "so":{"id":178211,"website_url":"http://www.hackperneurialism.com","link":"http://stackoverflow.com/users/178211/jonathon-kresner","reputation":490,"profile_image":"http://i.stack.imgur.com/FVija.jpg?g=1&s=128"},
            "bb":{"id":"hackerpreneur"}
          _id: "51799ece28904c2a04000087"
          availability: []
          events: []
        }
      ]
    availability: 'yo im free',
    events: [ { utc: '2013-04-02T04:35:52.256Z', name: 'created' } ]
    tags:
      [
        {
          ghId: undefined,
          soId: 'objective-c',
          short: 'objectiveC',
          name: 'Objective-C'
        }
      ]
  }

  # 3) Used in tests server/api/requests
  {
    _id:"518547fd350d480200000006"
    company:
      _id: "518546f8350d480200000004"
      contacts:[{"fullName":"Roger Toor","email":"roger@rolepoint.com","gmail":"roger@rolepoint.com","title":"","phone":"","userId":"5185464966a6f999a465f2b1","pic":"https://lh3.googleusercontent.com/-4OxBnF9RH78/AAAAAAAAAAI/AAAAAAAAABc/lAmApoSiVUs/photo.jpg","twitter":"rogertoor","timezone":"GMT+0100 (BST)","_id":"518546f8350d480200000005"}]
      name:"RolePoint"
      url:"www.rolepoint.com"
      about:"Reimagining sourcing for the enterprise.\n\nWe build software that changes the way talent is sourced. We’re rethinking the way organizations access candidates and are driving the shift in how enterprise uses technology to hire."
    hours:"1",
    budget:90,
    pricing:"private"
    brief:"Interviewing candidates. We're currently hiring an iOS developer and thus would like someone that has a lot of experience working with the platform to interview candidates and assess their ability, providing recommendations to the CTO on whether to hire. The format of the interview would be 50 minutes carried out over a recorded Google Hangout, thus allowing screen sharing to take place while the candidate conducts a mixture of Q&A alongside live coding and explaining projects they worked on recently. The remaining 10 minutes is reserved to provide feedback to the CTO."
    availability:"Interviews take place in UK evenings: 6-9pm BST / 10am - 1pm PST"
    status:"received"
    calls:[]
    suggested:[]
    events:[{"name":"created","utc":"2013-05-04T17:40:13.957Z"}]
    tags:[{"_id":"514825fa2a26ea020000001b","name":"iOS","short":"ios","soId":"ios"}]
  }

  # 4) Expert suggestions
  {
    suggested: [
      {
        "expert": {
          "brief": "Bring me your hard problems! I've designed everything from video surveillance systems on military aircraft to cell phone chipsets. These days, I especially enjoy working with startups to build mobile applications that interact with cloud-based backend services. I've built around 30 iOS applications, and I'm pretty dangerous with Ruby on Rails too. Multi-system communication can be very tricky, and I have a lot of experience solving those kinds of problems.",
          "email": "jason@ninjanetic.com",
          "gh": { "id": 162983, "username": "jznadams", "location": null, "blog": "www.ninjanetic.com", "gravatar_id": "28ea3aeec38c19ae698e60b08694e480", "followers": 1 },
          "gmail": "jason@ninjanetic.com",
          "homepage": "www.ninjanetic.com",
          "hours": "3-5",
          "in": { "id": "inDbmDh3cp", "displayName": "Jason Adams" },
          "name": "Jason Adams",
          "other": "",
          "pic": "https://secure.gravatar.com/avatar/28ea3aeec38c19ae698e60b08694e480",
          "rate": 110,
          "so": { "link": "" },
          "status": "ready",
          "timezone": "GMT-0500 (CDT)",
          "tw": { "id": 488483083, "username": "Ninjanetic" },
          "userId": "518477c866a6f999a465f2b0",
          "username": "jznadams",
          "karma": 0,
          "tags": [
            { "name": "Android", "short": "android", "soId": "android" },
            { "name": "iOS", "short": "ios", "soId": "ios" },
          ]
        }
      }
      {
        "expert": {
          "_id": "51549f70d96db10200000062",
          "brief": "Learning iOS Development.  Getting over iOS programming bugs or architecture decisions.  Implementing unit testing and TDD in iOS.",
          "email": "jcamealy@gmail.com",
          "gh": { "username": "bearMountain" },
          "gmail": "jcamealy@gmail.com",
          "homepage": "homebearco.com",
          "hours": "1",
          "name": "Jeffrey Camealy",
          "other": "",
          "pic": "https://lh4.googleusercontent.com/-Oy8DWLey9es/AAAAAAAAAAI/AAAAAAAAAAA/iPECpE2eK_E/photo.jpg",
          "rate": 70,
          "so": { "link": "888507/bearmountain" },
          "status": "ready",
          "timezone": "GMT-0500 (CDT)",
          "userId": "5182a00266a6f999a465f29c",
          "username": "bearMountain",
          "karma": 0,
          "tags": [ { "soId": "ios", "short": "ios", "name": "iOS", "_id": "514825fa2a26ea020000001b" } ],
        }
      }
      {
        "expert": {
          "_id": "515b6eb4eb8547020000003e",
          "brief": "Whatever.",
          "email": "humphriesj@gmail.com",
          "gh": { "id": 1637617, "username": "humphriesjm", "location": "Raleigh, NC", "blog": null, "gravatar_id": "5d8d3adbf7915863ec0a4484795923b3", "followers": 2 },
          "gmail": "humphriesj@gmail.com",
          "homepage": "",
          "hours": "2",
          "in": { "id": "GYElf7Gsqh", "displayName": "Jason Humphries" },
          "name": "Jason Humphries",
          "other": "",
          "pic": "https://lh3.googleusercontent.com/-o78abg7SN1A/AAAAAAAAAAI/AAAAAAAAAl8/wyl6r45RbvU/photo.jpg",
          "rate": 70,
          "so": { "id": 1096751, "website_url": "http://www.linkedin.com/pub/jason-humphries/19/34b/b32", "link": "1096751/humphriesj", "reputation": 69, "profile_image": "http://www.gravatar.com/avatar/5d8d3adbf7915863ec0a4484795923b3?d=identicon&r=PG" },
          "status": "ready",
          "timezone": "GMT-0400 (EDT)",
          "tw": { "id": 58227067, "username": "humphriesjm" },
          "userId": "518283dd66a6f999a465f290",
          "username": "humphriesjm",
          "karma": 0,
          "tags": [
            { "name": "heroku", "short": "heroku", "soId": "heroku" },
            { "soId": "facebook-connect", "short": "facebook-connect", "name": "facebook-connect", "_id": "5181d0aa66a6f999a465eddf" },
            { "soId": "ios", "short": "ios", "name": "iOS", "_id": "514825fa2a26ea020000001b" }
          ]
        }
      }
    ]
  }

  # 5) Used in test server/api/requests
  {
    "availability": "non-urgent, but would like to have someone i could meet with 1/wk for the next 4-8wks to accelerate my launch-date ",
    "brief": "general node.js + express work would be helpful, and database help - I have chosen postgres > mongod because it's what i am most comfortable with, still playing around with different ORMs but I like this one ---> https://github.com/dresende/node-orm2 \n\nbiggest concern of the moment is structuring scrapers and/or api calls firing in what that keeps all my data up to date and quickly searchable \n\n",
    "budget": 30,
    "company": {
      "about": "california camping is a tool to discover and reserve campsites. node.js, express, & jade. 140 char is long!! like longer than i'd like it to be. ",
      "url": "http://signup.californiacamping.ca/",
      "name": "california camping",
      "contacts": [
        {
          "_id": "5181f28b2e7e450200000005",
          "timezone": "GMT-0700 (PDT)",
          "twitter": "alyraz",
          "pic": "https://lh4.googleusercontent.com/-r9KnRjqx3m8/AAAAAAAAAAI/AAAAAAAAADA/Ssf-_fM5-dE/photo.jpg",
          "userId": "5181f23d66a6f999a465f284",
          "phone": "",
          "title": "",
          "gmail": "alyssaravasio@gmail.com",
          "email": "alyssaravasio@gmail.com",
          "fullName": "Alyssa Ravasio"
        }
      ],
      "_id": "5181f28b2e7e450200000004"
    },
    "hours": "1",
    "pricing": "opensource",
    "status": "review",
    "userId": "5181f23d66a6f999a465f284",
    "calls": [],
    "suggested": [
      {
        "expert": {
          "tags": [{ "_id": "514825fa2a26ea0200000028", "name": "NodeJS", "short": "node", "soId": "node.js" }],
          "karma": 0,
          "username": "jkresner",
          "userId": "5181d1f666a6f999a465f280",
          "timezone": "GMT-0700 (PDT)",
          "status": "ready",
          "so": {
            "id": 178211,
            "website_url": "http://www.hackerpreneurialism.com",
            "link": "178211/jonathon-kresner",
            "reputation": 495,
            "profile_image": "http://i.stack.imgur.com/FVija.jpg?g=1&s=128"
          },
          "rate": 110,
          "pic": "https://lh3.googleusercontent.com/-daU--wCrRcI/AAAAAAAAAAI/AAAAAAAAADA/_BUOhjJeNkk/photo.jpg",
          "name": "Jonathon Kresner",
          "homepage": "hackerpreneurialism.com",
          "gmail": "jkresner@gmail.com",
          "gh": {
            "id": 979542,
            "username": "jkresner",
            "location": "San Francisco",
            "blog": "hackerpreneurialism.com",
            "gravatar_id": "780d02a99798886da48711d8104801a4",
            "followers": 15
          },
          "email": "jkresner@gmail.com",
          "brief": "Learning frameworks, creating good project structures / architecture. Pair programming.",
          "_id": "5181d4ccf3dc070200000004"
        },
        "expertStatus": "waiting",
        "_id": "518ac2ecc4a40e7a4b00000a",
        "events": [
          {
            "utc": "2013-05-08T21:26:04.276Z",
            "by": { "name": "Jonathon Kresner", "id": "5175efbfa3802cc4d5a5e6ed" },
            "name": "first contacted"
          }
        ]
      }
    ],
    "events": [ { "utc": "2013-05-02T05:01:59.284Z", "name": "created" } ],
    "tags": [
      { "soId": "node.js", "short": "node", "name": "NodeJS", "_id": "514825fa2a26ea0200000028" },
      { "soId": "express", "short": "express", "name": "ExpressJS", "_id": "514825fa2a26ea0200000016" }
    ]
  }

  # 6) Expert feedback
  {
    nothanks:
      expert:
        tags: [ { "soId": "node.js", "short": "node", "name": "NodeJS", "_id": "514825fa2a26ea0200000028" } ]
        username: 'jkresner'
        userId: '5181d1f666a6f999a465f280'
        tw: { id: 21989578, username: 'hackerpreneur' }
        timezone: 'GMT-0700 (PDT)'
        status: 'ready'
        so: { id: 178211, website_url: 'http://www.hackerpreneurialism.com', link: '178211/jonathon-kresner', reputation: 495 }
        rate: 110,
        pic: 'https://lh3.googleusercontent.com/-daU--wCrRcI/AAAAAAAAAAI/AAAAAAAAADA/_BUOhjJeNkk/photo.jpg',
        name: 'Jonathon Kresner',
        in: { id: 'd9YFKgZ7rY', displayName: 'Jonathon Kresner' }
        homepage: 'hackerpreneurialism.com'
        gmail: 'jkresner@gmail.com'
        gh: { id: 979542, username: 'jkresner', location: 'San Francisco', blog: 'hackerpreneurialism.com', gravatar_id: '780d02a99798886da48711d8104801a4', followers: 15 }
        email: 'jkresner@gmail.com'
        brief: 'Learning frameworks, creating good project structures / architecture. Pair programming.',
        bb: { id: 'hackerpreneur' }
        _id: '5181d4ccf3dc070200000004'
      expertStatus: 'abstained',
      _id: '518ac2ecc4a40e7a4b00000a'
      events: [ { utc: '2013-05-08T21:26:04.276Z', by: [Object], name: 'first contacted' } ]
      requestId: '5181f3472e7e450200000007'
      custPic: 'https://lh4.googleusercontent.com/-r9KnRjqx3m8/AAAAAAAAAAI/AAAAAAAAADA/Ssf-_fM5-dE/photo.jpg'
      expertRating: '1'
      expertFeedback: 'asdfasdfasdasdfasdfasdasdfasdfasdasdfasdfasdasdfasdfasdasdfasdfasd'
      expertComment: 'asdfasdfasdf'
      expertAvailability: 'unavailable'
  }

  # 7) Review request
  {
    availability: "SFO",
    brief: "I need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen. I need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen.\nI need better coverage for my review screen. I need better coverage for my review screen.",
    budget: 90,
    canceledDetail: "",
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
    hours: "1",
    pricing: "opensource",
    status: "review",
    userId: "5175efbfa3802cc4d5a5e6ed",
    calls: [],
    suggested: [
      {
        expert: {
          "tags": [
            "soId": "flex", "short": "Flex", "name": "Flex"
            "soId": "angularjs", "short": "AngularJS", "name": "AngularJS"
            "soId": "actionscript-3", "short": "ActionScript3", "name": "ActionScript 3"
          ],
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
        events: [
          "utc": "2013-06-07T22:09:27.163Z", "name": "first contacted", "by": { "name": "Jonathon Kresner", "id": "5175efbfa3802cc4d5a5e6ed" }
        ]
      }
    ],
    events: [ name: "created", utc: "2013-06-07T22:08:36.756Z", by: { "id": "5175efbfa3802cc4d5a5e6ed", "name": "Jonathon Kresner" } ],
    tags: [
      _id: "514825fa2a26ea0200000024", "name": "Mocha", "short": "mocha", "soId": "mocha"
      _id: "514825fa2a26ea0200000011", "name": "CoffeeScript", "short": "coffee", "soId": "coffeescript"
      _id: "5181d0ab66a6f999a465efa1", "name": "integration-testing", "short": "integration-testing", "soId": "integration-testing"
      _id: "5181d0a966a6f999a465eba1", "name": "testing", "short": "testing", "soId": "testing"
      _id: "5181d0aa66a6f999a465ed8e", "name": "tdd", "short": "tdd", "soId": "tdd"
    ]
  }


]