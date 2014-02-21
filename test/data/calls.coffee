module.exports = [

  # 0) not used
  {}

  # 1) call object with paul cavanese's expertId
  { type: 'opensource', expertId: '52372c73a9b270020000001c', duration: 1, datetime: new Date() }

  # 2) call object with paul cavanese's expertId, 2 duration
  { type: 'opensource', expertId: '52372c73a9b270020000001c', duration: 2, datetime: new Date() }

  # 3) kirk scheduling a 2 hour open source with james
  { type: 'opensource', expertId: '52726d7ef7f1d40200000015', duration: 2, datetime: new Date(), notes: '', recordings: [] }

  # 4) kirk scheduling a 5 hour private with james
  { type: 'private', expertId: '52726d7ef7f1d40200000015', duration: 5, datetime: new Date(), notes: '', recordings: [] }

  # 5) tinfow scheduling a 5 hour private call with domenic
  {"expertId":"5296c8964546790200000032","type":"private","duration":5,"datetime":"2014-01-08T20:00:00.000Z","status":"pending","_id":"53064e86428a700000000013","recordings":[],"notes":"more notes"}
]
