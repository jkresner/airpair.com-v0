global._ = require 'lodash'
Factory = require('factory-lady')
UserModel = require('../../lib/models/user')

Factory.define 'dhhUser', UserModel,
  googleId: '100025457193287284665'
  github:
    provider: "github"
    id: 979542
    displayName: "Jonathon Kresner"
    username: "jkresner"
    profileUrl: "https://github.com/jkresner"
    _json:
      login: "jkresner"
      id: 979542
      avatar_url: "https://avatars.githubusercontent.com/u/979542?"
      gravatar_id: "780d02a99798886da48711d8104801a4"
      url: "https://api.github.com/users/jkresner"
      html_url: "https://github.com/jkresner"
      followers_url: "https://api.github.com/users/jkresner/followers"
      following_url: "https://api.github.com/users/jkresner/following{/other_user}"
      gists_url: "https://api.github.com/users/jkresner/gists{/gist_id}"
      starred_url: "https://api.github.com/users/jkresner/starred{/owner}{/repo}"
      subscriptions_url: "https://api.github.com/users/jkresner/subscriptions"
      organizations_url: "https://api.github.com/users/jkresner/orgs"
      repos_url: "https://api.github.com/users/jkresner/repos"
      events_url: "https://api.github.com/users/jkresner/events{/privacy}"
      received_events_url: "https://api.github.com/users/jkresner/received_events"
      type: "User"
      site_admin: false
      name: "Jonathon Kresner"
      company: "airpair, inc."
      blog: "hackerpreneurialism.com"
      location: "San Francisco"
      email: null
      hireable: false
      bio: null
      public_repos: 17
      public_gists: 19
      followers: 36
      following: 37
      created_at: "2011-08-14T17:14:37Z"
      updated_at: "2014-06-18T16:46:53Z"
    token:
      token: "b5cd0b93ae366fa45756b5d1dcbd1eef2225445b"
      attributes:
        refreshToken: null
