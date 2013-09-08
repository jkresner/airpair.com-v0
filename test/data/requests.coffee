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
      contacts: [
        {
          "fullName": "Jonathon Kresner", "email": "jk@airpair.com", "gmail": "jk@airpair.com",
          "userId": "5175efbfa3802cc4d5a5e6ed", "_id": "51b259ac22ddda020000000b"
        }]
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

  # 8) Review book request emilLee + 3 experts
  {"availability":"New York. Available after business hours on weekdays, any time weekends. ","brief":"I want help firstly with CSS / design. I will ask for assistance with building a \"business card\" online (using HTML / CSS), and then also a profile.\n\nAfter that, would like help building the front end interaction (JS/AJAX) and back end (rails/postgres). ","budget":60,"calls":[],"canceledDetail":"","company":{"_id":"51af95ea900c860200000005","contacts":[{"fullName":"Emil Lee","email":"ehl258@stern.nyu.edu","gmail":"ehl258@stern.nyu.edu","title":"","phone":"","userId":"51af958f66a6f999a465f37a","pic":"","twitter":"","timezone":"GMT-0400 (Eastern Da","_id":"51af95ea900c860200000006"}],"name":"WPack","url":"","about":"Looking to build a professional networking website that helps users continuously accomplish their professional goals. For example, mutual introductions through connections.","__v":0,"mailTemplates":{"received":"%0A%0A\nWe've got your ruby-on-rails and CSS request and will start looking around {insert time frame here}. Do you have any idea how many hours you'd like to book? Ok if you don't, but if you do it will guide us to find an expert with matching availability.\n%0A%0A\nAlso, how did you hear about us?\n%0A%0A\nLooking forward to working together!\n\n%0A%0A--\n%0AJonathon Kresner\n%0Atwitter.com/airpair\n%0Ameetup.com/remotepairprogrammers","review":"%0A%0A\nWe shortlisted a few experts for your airpair. Take a look:\n%0A%0A\nhttp://www.airpair.com/review/51af966e900c860200000007\n%0A%0A\nPlease indicate which expert(s) you would like to pair with and then reply to this email.\n\n%0A%0A--\n%0AJonathon Kresner\n%0Atwitter.com/airpair\n%0Ameetup.com/remotepairprogrammers","matched":"%0A%0A\nWe've got a match! {insert name} has agreed to jump on airpair.\n%0A%0A\nI've invited you to a private hipchat room. Use this chat room to agree on a time with your expert. You can also ask any unanswered questions here before you jump on call.\n%0A%0A\nOnce you have a time, I'll send you a google calendar\ninvite so you have it in your diary. Please confirm the\n time appears correct in your timezone and then accept the invitation.\n%0A%0A\nWe'll implement proper payment functionality soon. For now can you please deposit ${amount} via paypal to jkresner@gmail.com\n%0A%0A\nBe ready 10 minutes before your call. We hard finish on the hour so as not to affect customers after you. A few minutes before your airpair, someone from our team will invite you to a google hangout to record your session. We record sessions so you can watch them back anytime in case you miss something the expert explains to you.\n\n%0A%0A--\n%0AJonathon Kresner\n%0Atwitter.com/airpair\n%0Ameetup.com/remotepairprogrammers","followup":" thanks again for yesterday! Here's your recording for you to refer to anytime.\n%0A%0A\n{link}\n%0A%0A\nIf you have any useful feedback for airpair (e.g. to improve the experience or for PR ammunition) please drop it in a reply to this email. Please include feedback on your expert {name here} to help them build credibility for other customers to see.\n%0A%0A\nIs there anything else we can help you with? Many customers buy 5-20 hour packages that they use to check in with experts once or twice a week. We're currently running a special - $10 discount for every hour in your package (so up to $200 off a 20 hour pkg).\n%0A%0A\nLastly are you on angellist? If so would it be ok to list you as a customer on our profile?\n%0A%0A\nhttp://angel.co/airpair\n%0A%0A\nThanks for trying airpair :)!\n\n%0A%0A--\n%0AJonathon Kresner\n%0Atwitter.com/airpair\n%0Ameetup.com/remotepairprogrammers"},"tagsString":"ruby-on-rails and CSS"},"events":[{"utc":"2013-06-17T00:02:41.940Z","name":"anon view","by":"anon"},{"name":"expert reviewed","by":{"id":"51a4d2a466a6f999a465f2f1","name":"Richard Kuo"},"utc":"2013-06-10T16:54:34.269Z","data":{"expert":{"tags":[{"_id":"514825fa2a26ea0200000031","name":"Ruby Motion","short":"ruby","soId":"ruby"},{"_id":"514825fa2a26ea020000002f","name":"ruby-on-rails","short":"ruby-on-rails","soId":"ruby-on-rails"},{"_id":"5181d0ad66a6f999a465f1be","name":"javascript-library","short":"javascript-library","soId":"javascript-library"},{"_id":"514825fa2a26ea0200000021","name":"jQuery","short":"jquery","soId":"jquery"},{"_id":"5181d0a966a6f999a465ebcb","name":"twitter-bootstrap","short":"twitter-bootstrap","soId":"twitter-bootstrap"},{"_id":"514deb4aca38eb0200000018","name":"foundation","short":"foundation","soId":"foundation"},{"_id":"5181d0ad66a6f999a465f1a5","name":"photoshop","short":"photoshop","soId":"photoshop"},{"_id":"5181d0a966a6f999a465eb54","name":"excel","short":"excel","soId":"excel"},{"_id":"514825fa2a26ea020000002c","name":"PostgreSQL","short":"Postgres","soId":"postgres"}],"karma":0,"username":"richkuo","userId":"51a4d2a466a6f999a465f2f1","timezone":"GMT-0400 (EDT)","status":"ready","rate":70,"pic":"https://secure.gravatar.com/avatar/10f800e74ff94ada0ef4cb483d183939","name":"Richard Kuo","hours":"1","homepage":"","gmail":"richard.p.kuo@gmail.com","gh":{"followers":2,"gravatar_id":"10f800e74ff94ada0ef4cb483d183939","blog":null,"location":null,"username":"richkuo","id":880112},"email":"richard.p.kuo@gmail.com","brief":"i love to tackle tough problems, i also enjoy helping newbies (i used to be one), i like designing simple and elegant web pages with bootstrap/foundation, i like to help with business strategies for new ideas, i also photoshop a lot, and have a solid background in excel","_id":"51a4d2b47021eb0200000009","__v":0},"suggestedRate":70,"expertStatus":"available","_id":"51b2087622ddda0200000004","events":[{"utc":"2013-06-07T16:21:10.902Z","by":{"name":"Jonathon Kresner","id":"5175efbfa3802cc4d5a5e6ed"},"name":"first contacted"},{"name":"viewed","by":{"id":"51a4d2a466a6f999a465f2f1","name":"Richard Kuo"},"utc":"2013-06-10T16:47:17.875Z"}],"requestId":"51af966e900c860200000007","expertRating":"4","expertFeedback":"Back end - Ruby developer with experience using Rails and Sinatra.\nFront end - Plenty of front end development using JS and Jquery\nDesign - Experience with Photoshop, CSS, SCSS, Bootstrap, Foundation, UI/UX design.\nBusiness - Sales, marketing, product, strategies, data analysis.","expertComment":"My skillset:\nBack end - Ruby developer with experience using Rails and Sinatra.\nFront end - Experience with JS, JQuery, and front end frameworks.\nDesign - Experience with Photoshop, CSS, SCSS, Bootstrap, Foundation, UI/UX design.\nBusiness - Sales, marketing, product, strategy, data analysis.","expertAvailability":"New York. Available after business hours on weekdays, any time weekends. Eastern time."}},{"name":"expert view","by":{"id":"51a4d2a466a6f999a465f2f1","name":"Richard Kuo"},"utc":"2013-06-10T16:47:17.873Z"},{"name":"customer view","by":{"id":"51af958f66a6f999a465f37a","name":"Emil Lee"},"utc":"2013-06-10T15:48:14.472Z"},{"name":"suggested richkuo","by":{"id":"5175efbfa3802cc4d5a5e6ed","name":"Jonathon Kresner"},"utc":"2013-06-07T16:21:10.897Z"},{"name":"suggested mattvanhorn","by":{"id":"5175efbfa3802cc4d5a5e6ed","name":"Jonathon Kresner"},"utc":"2013-06-06T23:28:10.703Z"},{"name":"created","by":{"id":"51af958f66a6f999a465f37a","name":"Emil Lee"},"utc":"2013-06-05T19:50:06.304Z"},{"utc":"2013-06-06T23:28:14.561Z","by":{"name":"Jonathon Kresner","id":"5175efbfa3802cc4d5a5e6ed"},"name":"suggested requnix"},{"utc":"2013-06-07T00:04:06.138Z","by":{"name":"Matthew Van Horn","id":"51b0c2c366a6f999a465f389"},"name":"expert view"},{"data":{"expertAvailability":"unavailable","expertComment":"It seems like you need someone whose strength is more on the visual/UX design side, at least to start out. Happy to work with you when you're ready to move on to writing code.","expertFeedback":"It sounds like the requestor is looking for someone with more front-end and graphic design experience, for at least the primary phase of this project. I'd be happy if he wants to get back to me when he starts on the actual web application. He should really split this request up, it will be hard to find a person really good at both.","expertRating":"2","requestId":"51af966e900c860200000007","events":[{"name":"first contacted","by":{"id":"5175efbfa3802cc4d5a5e6ed","name":"Jonathon Kresner"},"utc":"2013-06-06T23:28:10.703Z"},{"utc":"2013-06-07T00:04:06.139Z","by":{"name":"Matthew Van Horn","id":"51b0c2c366a6f999a465f389"},"name":"viewed"}],"_id":"51b11b0aaa6f420200000018","expertStatus":"abstained","suggestedRate":40,"expert":{"__v":0,"_id":"51b0c417900c860200000018","brief":"I enjoy helping people learn to useTDD/BDD effectively, to write well-crafted, easily maintainable, expressive OO ruby code, and to help them refactor projects that have gotten out of hand.\nSample project:\nhttp://www.livingbjj.com\nhttps://github.com/mattvanhorn/BJJLife\nhttps://codeclimate.com/github/mattvanhorn/BJJLife\n","email":"mattvanhorn@gmail.com","gh":{"id":20461,"username":"mattvanhorn","location":"San Francisco","blog":"www.mattvanhorn.com","gravatar_id":"985ff04dc441ad87b0cefcd31823575d","followers":17},"gmail":"mattvanhorn@gmail.com","homepage":"www.mattvanhorn.com","hours":"1","in":{"id":"W69cKyHWoZ","displayName":"Matthew Van Horn"},"name":"Matthew Van Horn","pic":"https://secure.gravatar.com/avatar/985ff04dc441ad87b0cefcd31823575d","rate":40,"so":{"id":12651,"website_url":"http://www.mattvanhorn.com","link":"12651/matt-van-horn","reputation":879,"profile_image":"http://www.gravatar.com/avatar/985ff04dc441ad87b0cefcd31823575d?d=identicon&r=PG"},"status":"ready","timezone":"GMT-0700 (PDT)","tw":{"id":14090030,"username":"nycplayer"},"userId":"51b0c2c366a6f999a465f389","username":"mattvanhorn","karma":0,"tags":[{"_id":"5181d0ad66a6f999a465f19f","name":"rspec2","short":"rspec2","soId":"rspec2"},{"_id":"514825fa2a26ea0200000031","name":"Ruby Motion","short":"ruby","soId":"ruby"},{"_id":"514825fa2a26ea020000002f","name":"ruby-on-rails","short":"ruby-on-rails","soId":"ruby-on-rails"},{"_id":"5181d0aa66a6f999a465ee0b","name":"cucumber","short":"cucumber","soId":"cucumber"},{"soId":"tdd","short":"tdd","name":"tdd","_id":"5181d0aa66a6f999a465ed8e"},{"soId":"bdd","short":"bdd","name":"Behavior Driven Development","_id":"514825fa2a26ea020000000a"},{"soId":"agile","short":"agile","name":"agile","_id":"5181d0ad66a6f999a465f1af"},{"soId":"oop","short":"oop","name":"oop","_id":"5181d0a966a6f999a465eb65"}],"hasLinks":true}},"utc":"2013-06-07T00:08:29.980Z","by":{"name":"Matthew Van Horn","id":"51b0c2c366a6f999a465f389"},"name":"expert reviewed"}],"hours":"1","incompleteDetail":"","pricing":"opensource","status":"review","suggested":[{"expertAvailability":"unavailable","expertComment":"It seems like you need someone whose strength is more on the visual/UX design side, at least to start out. Happy to work with you when you're ready to move on to writing code.","expertFeedback":"It sounds like the requestor is looking for someone with more front-end and graphic design experience, for at least the primary phase of this project. I'd be happy if he wants to get back to me when he starts on the actual web application. He should really split this request up, it will be hard to find a person really good at both.","expertRating":2,"expert":{"hasLinks":true,"tags":[{"soId":"rspec2","short":"rspec2","name":"rspec2","_id":"5181d0ad66a6f999a465f19f"},{"soId":"ruby","short":"ruby","name":"Ruby Motion","_id":"514825fa2a26ea0200000031"},{"soId":"ruby-on-rails","short":"ruby-on-rails","name":"ruby-on-rails","_id":"514825fa2a26ea020000002f"},{"soId":"cucumber","short":"cucumber","name":"cucumber","_id":"5181d0aa66a6f999a465ee0b"},{"_id":"5181d0aa66a6f999a465ed8e","name":"tdd","short":"tdd","soId":"tdd"},{"_id":"514825fa2a26ea020000000a","name":"Behavior Driven Development","short":"bdd","soId":"bdd"},{"_id":"5181d0ad66a6f999a465f1af","name":"agile","short":"agile","soId":"agile"},{"_id":"5181d0a966a6f999a465eb65","name":"oop","short":"oop","soId":"oop"}],"karma":0,"username":"mattvanhorn","userId":"51b0c2c366a6f999a465f389","tw":{"username":"nycplayer","id":14090030},"timezone":"GMT-0700 (PDT)","status":"ready","so":{"profile_image":"http://www.gravatar.com/avatar/985ff04dc441ad87b0cefcd31823575d?d=identicon&r=PG","reputation":879,"link":"12651/matt-van-horn","website_url":"http://www.mattvanhorn.com","id":12651},"rate":40,"pic":"https://secure.gravatar.com/avatar/985ff04dc441ad87b0cefcd31823575d","name":"Matthew Van Horn","in":{"displayName":"Matthew Van Horn","id":"W69cKyHWoZ"},"hours":"1","homepage":"www.mattvanhorn.com","gmail":"mattvanhorn@gmail.com","gh":{"followers":17,"gravatar_id":"985ff04dc441ad87b0cefcd31823575d","blog":"www.mattvanhorn.com","location":"San Francisco","username":"mattvanhorn","id":20461},"email":"mattvanhorn@gmail.com","brief":"I enjoy helping people learn to useTDD/BDD effectively, to write well-crafted, easily maintainable, expressive OO ruby code, and to help them refactor projects that have gotten out of hand.\nSample project:\nhttp://www.livingbjj.com\nhttps://github.com/mattvanhorn/BJJLife\nhttps://codeclimate.com/github/mattvanhorn/BJJLife\n","_id":"51b0c417900c860200000018","__v":0},"suggestedRate":{"opensource":{"expert":40,"total":60},"private":{"expert":40,"total":80},"nda":{"expert":60,"total":130}},"expertStatus":"abstained","_id":"51b11b0aaa6f420200000018","events":[{"utc":"2013-06-06T23:28:10.703Z","by":{"name":"Jonathon Kresner","id":"5175efbfa3802cc4d5a5e6ed"},"name":"first contacted"},{"name":"viewed","by":{"id":"51b0c2c366a6f999a465f389","name":"Matthew Van Horn"},"utc":"2013-06-07T00:04:06.139Z"},{"utc":"2013-06-07T00:08:29.980Z","by":{"name":"Matthew Van Horn","id":"51b0c2c366a6f999a465f389"},"name":"expert updated"}],"tags":[{"_id":"514825fa2a26ea020000002f","name":"ruby-on-rails","short":"ruby-on-rails","soId":"ruby-on-rails"},{"_id":"514825fa2a26ea0200000013","name":"CSS","short":"css","soId":"css"}]},{"expert":{"hasLinks":true,"tags":[{"_id":"514825fa2a26ea020000002f","name":"ruby-on-rails","short":"ruby-on-rails","soId":"ruby-on-rails"},{"_id":"514825fa2a26ea0200000011","name":"CoffeeScript","short":"coffee","soId":"coffeescript"},{"_id":"5181d0aa66a6f999a465ee7b","name":"relational-database","short":"relational-database","soId":"relational-database"}],"karma":0,"username":"requnix","userId":"51a465d566a6f999a465f2ee","tw":{"username":"michael_prins","id":40884571},"timezone":"GMT+0200 (SAST)","status":"busy","so":{"profile_image":"http://www.gravatar.com/avatar/ad641961a030d715748458c7511ea4da?d=identicon&r=PG","reputation":91,"link":"1264269/requnix","website_url":"","id":1264269},"rate":40,"pic":"https://lh6.googleusercontent.com/-mwLiQp42QCo/AAAAAAAAAAI/AAAAAAAAAFA/oY5FP-maKOs/photo.jpg","name":"Michael Prins","in":{"displayName":"Michael Prins","id":"FvfkHwMjRp"},"hours":"1","homepage":"about.me/requnix","gmail":"requnix@gmail.com","gh":{"followers":4,"gravatar_id":"ad641961a030d715748458c7511ea4da","blog":"http://about.me/requnix","location":"Cape Town, South Africa","username":"requnix","id":292062},"email":"requnix@gmail.com","brief":"I'm happy to help developers starting with Rails, explaining patterns and conventions if need be, all the way to more experienced developers looking for advice on database design, third-party services, testing and troubleshooting.","bb":{"id":"reQunix"},"_id":"51a466707021eb0200000004","__v":0},"suggestedRate":{"opensource":{"expert":40,"total":60},"private":{"expert":40,"total":80},"nda":{"expert":60,"total":130}},"expertStatus":"waiting","_id":"51b11b0eaa6f420200000019","events":[{"utc":"2013-06-06T23:28:14.561Z","by":{"name":"Jonathon Kresner","id":"5175efbfa3802cc4d5a5e6ed"},"name":"first contacted"}],"tags":[{"_id":"514825fa2a26ea020000002f","name":"ruby-on-rails","short":"ruby-on-rails","soId":"ruby-on-rails"},{"_id":"514825fa2a26ea0200000013","name":"CSS","short":"css","soId":"css"}]},{"expertAvailability":"New York. Available after business hours on weekdays, any time weekends. Eastern time.","expertComment":"My skillset:\nBack end - Ruby developer with experience using Rails and Sinatra.\nFront end - Experience with JS, JQuery, and front end frameworks.\nDesign - Experience with Photoshop, CSS, SCSS, Bootstrap, Foundation, UI/UX design.\nBusiness - Sales, marketing, product, strategy, data analysis.","expertFeedback":"Back end - Ruby developer with experience using Rails and Sinatra.\nFront end - Plenty of front end development using JS and Jquery\nDesign - Experience with Photoshop, CSS, SCSS, Bootstrap, Foundation, UI/UX design.\nBusiness - Sales, marketing, product, strategies, data analysis.","expertRating":4,"expert":{"tags":[{"_id":"514825fa2a26ea0200000031","name":"Ruby Motion","short":"ruby","soId":"ruby"},{"_id":"514825fa2a26ea020000002f","name":"ruby-on-rails","short":"ruby-on-rails","soId":"ruby-on-rails"},{"_id":"5181d0ad66a6f999a465f1be","name":"javascript-library","short":"javascript-library","soId":"javascript-library"},{"_id":"514825fa2a26ea0200000021","name":"jQuery","short":"jquery","soId":"jquery"},{"_id":"5181d0a966a6f999a465ebcb","name":"twitter-bootstrap","short":"twitter-bootstrap","soId":"twitter-bootstrap"},{"_id":"514deb4aca38eb0200000018","name":"foundation","short":"foundation","soId":"foundation"},{"_id":"5181d0ad66a6f999a465f1a5","name":"photoshop","short":"photoshop","soId":"photoshop"},{"_id":"5181d0a966a6f999a465eb54","name":"excel","short":"excel","soId":"excel"},{"_id":"514825fa2a26ea020000002c","name":"PostgreSQL","short":"Postgres","soId":"postgres"}],"karma":0,"username":"richkuo","userId":"51a4d2a466a6f999a465f2f1","timezone":"GMT-0400 (EDT)","status":"ready","rate":70,"pic":"https://secure.gravatar.com/avatar/10f800e74ff94ada0ef4cb483d183939","name":"Richard Kuo","hours":"1","homepage":"","gmail":"richard.p.kuo@gmail.com","gh":{"followers":2,"gravatar_id":"10f800e74ff94ada0ef4cb483d183939","blog":null,"location":null,"username":"richkuo","id":880112},"email":"richard.p.kuo@gmail.com","brief":"i love to tackle tough problems, i also enjoy helping newbies (i used to be one), i like designing simple and elegant web pages with bootstrap/foundation, i like to help with business strategies for new ideas, i also photoshop a lot, and have a solid background in excel","_id":"51a4d2b47021eb0200000009","__v":0,"hasLinks":true},"suggestedRate":{"opensource":{"expert":40,"total":60},"private":{"expert":40,"total":80},"nda":{"expert":60,"total":130}},"expertStatus":"available","_id":"51b2087622ddda0200000004","events":[{"utc":"2013-06-07T16:21:10.902Z","by":{"name":"Jonathon Kresner","id":"5175efbfa3802cc4d5a5e6ed"},"name":"first contacted"},{"name":"viewed","by":{"id":"51a4d2a466a6f999a465f2f1","name":"Richard Kuo"},"utc":"2013-06-10T16:47:17.875Z"},{"utc":"2013-06-10T16:54:34.268Z","by":{"name":"Richard Kuo","id":"51a4d2a466a6f999a465f2f1"},"name":"expert updated"}],"tags":[{"_id":"514825fa2a26ea020000002f","name":"ruby-on-rails","short":"ruby-on-rails","soId":"ruby-on-rails"},{"_id":"514825fa2a26ea0200000013","name":"CSS","short":"css","soId":"css"}]}],"tags":[{"_id":"514825fa2a26ea020000002f","name":"ruby-on-rails","short":"ruby-on-rails","soId":"ruby-on-rails"},{"_id":"514825fa2a26ea0200000013","name":"CSS","short":"css","soId":"css"}],"userId":"51af958f66a6f999a465f37a"}
]