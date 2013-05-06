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

  # 3) Used in test server/api/requests
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

  # 4) Not used
  {},
]