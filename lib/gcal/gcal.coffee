googleapis = require 'googleapis'
ONE_HOUR = 3600000 # milliseconds

OAuth2Client = googleapis.OAuth2Client
CLIENT_ID = "980673476043-qo125e4cghau62thkrb4igkm50a1rp0l.apps.googleusercontent.com"
CLIENT_SECRET = "T3OP1W-LjcdiS_cg8Ib8bBsc"
REDIRECT_URL = "https://www.airpair.com/oauth2callback"
oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL)

tokens = {
  # access_token: 'ya29.1.AADtN_UjZ6LFYsl-XpVIO-8tPNKOat3mMlt8a9cBB7qgFJLv8PJUDZKlGY1--rH6hhaBmA',
  # token_type: 'Bearer',
  # expires_in: 3600,
  refresh_token: '1/LYtNYz8ULvadUtjdWLEVy3vJeTB57blL75fGz87j5Uw'
}
oauth2Client.setCredentials(tokens)

cal = undefined

setupAPI = (cb) ->
  if cal then return cb(null, cal, oauth2Client)

  googleapis
    .discover 'calendar', 'v3'
    .execute (err, client) ->
      if err then return cb err
      cal = client.calendar
      cb null, client, oauth2Client

module.exports = setupAPI
