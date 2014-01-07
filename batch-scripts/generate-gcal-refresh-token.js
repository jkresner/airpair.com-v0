/**
 * Copyright 2012 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.

 */

/*
Once we have a refresh token generated for team@, then we hard-code it into
our app so that we can make new events on the team@ gcal page whenever we want

DO NOT RUN THIS FILE UNLESS YOU ALSO PASTE THE NEW REFRESH TOKEN INTO OUR APP
CODE. If you do not do this, the one the app uses will expire, and then the app
will not be able to make events via the API!
*/

var readline = require('readline');

var googleapis = require('../lib/googleapis.js');
var OAuth2Client = googleapis.OAuth2Client;

// Client ID and client secret are available at
// https://code.google.com/apis/console
var CLIENT_ID = "980673476043-qo125e4cghau62thkrb4igkm50a1rp0l.apps.googleusercontent.com";
var CLIENT_SECRET = "T3OP1W-LjcdiS_cg8Ib8bBsc";
var REDIRECT_URL = "https://www.airpair.com/oauth2callback";

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// load gcal API resources and methods
googleapis
.discover('calendar', 'v3')
.execute(function(err, client) {
  cal = client.calendar
  var oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL)

  // retrieve an access token
  getAccessToken(oauth2Client, function() {
    cal.calendarList.list().withAuthClient(oauth2Client)
    .execute(function(err, data) {
      if (err) return console.log(err)
      console.log('list', data)
    })
  });
});

function getAccessToken(oauth2Client, callback) {
  // generate consent page url
  var url = oauth2Client.generateAuthUrl({
    access_type: 'offline', // will return a refresh token
    scope: 'https://www.googleapis.com/auth/calendar',
    approval_prompt: 'force'
  });

  console.log('Visit the url: ', url);
  rl.question('Enter the code here:', function(code) {
    // request access token
    console.log('code', code)
    oauth2Client.getToken(code, function(err, tokens) {
      // set tokens to the client
      console.log('tokens', tokens)
      oauth2Client.setCredentials(tokens);
      callback();
    });
  });
}
