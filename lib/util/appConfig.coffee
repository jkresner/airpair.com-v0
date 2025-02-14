defaults =
  airconf:
    discountCodesUrl: 'http://spreadsheets.google.com/feeds/list/1oTVraiCyHBg6JrFpGMGf0wppXYVznDGJ3rLqYqvAawE/od6/public/values?alt=json'
    scheduleUrl: 'https://spreadsheets.google.com/feeds/list/19SMSYKdZJjRBw-Rfxc3Wl7XH41ItCkdmIsFYf4DePsY/1/public/values?alt=json'

module.exports =
  dev:
    defaults: defaults
    airconf:
      chat:
        firebasePath: 'https://airconf.firebaseio.com/chat/'
        firebaseSecret: 'PHQmJ3cVtcvdsWkb76fKTvIagbM5Ut1KFrDzSLmw'
    env: 'dev'
    isProd: false
    mongoUri: process.env.MONGOHQ_URL || "mongodb://localhost/airpair_dev"
    oauthHost: 'http://localhost:3332'
    analytics:
      segmentio:
        writeKey: 'tjld2les7x'
        settings: { flushAt: 1 }
      mixpanel:
        key: 'b5d4ee8855759e80e92b6b6433d5e43f'
        secret: '7c3544cdb3030ad7612e0c0315016390'
    mail:
      ses_access_key: process.env.AP_SES_ACCESS_KEY || "none"
      ses_secret_key: process.env.AP_SES_SECRET_KEY || "none"
    mailchimp:
      apiKey: 'b888ee9284cd0d57f425867c0bde3fe0-us7'
      airconfListId: '39f4769300'
    payment:
      stripe:
        publishedKey: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'
        secretKey: 'sk_test_8WOe71OlRWPyB3rDRcnthSCc'
      paypal:
        endpoint: 'https://svcs.sandbox.paypal.com/AdaptivePayments'
        primaryReceiver: 'jk-facilitator@airpair.com'
        SECURITYUSERID: 'jk-facilitator_api1.airpair.com',
        SECURITYPASSWORD: '1372567697',
        SECURITYSIGNATURE: 'An5ns1Kso7MWUdW4ErQKJJJ4qi4-AC6a0z5no3hrQwQyUMvBCahLxwBA'
        APPLICATIONID: 'APP-80W284485P519543T'
    google:
      passport:
        clientID: '739031114792.apps.googleusercontent.com'
        clientSecret: '8_1NuinvGy6ybpu0m2srvYjm'
      oauth:
        CLIENT_ID: "980673476043-qo125e4cghau62thkrb4igkm50a1rp0l.apps.googleusercontent.com"
        CLIENT_SECRET: "T3OP1W-LjcdiS_cg8Ib8bBsc"
        REDIRECT_URL: "https://www.airpair.com/oauth2callback"
      calendar:
        account: 'experts@airpair.com'
        params:
          calendarId: 'experts@airpair.com' # experts@ primary calendar ID
    linkedin:
      consumerKey: 'sy5n2q8o2i49'
      consumerSecret: 'lcKjdbFSNG3HfZsd'
    bitbucket:
      consumerKey: 'QNw3HsMSKzM6ptP4G4'
      consumerSecret: 'Cx5pvK2ZEjsymVxME42hSffkzkaQ9Buf'
    github:
      clientID: '378dac2743563e96c747'
      clientSecret: 'f52d233259426f769850a13c95bfc3dbe7e3dbf2'
    twitter:
      consumerKey: '8eIvjnVbj0BkMiUVQP0ZQ'
      consumerSecret: 'OwrnjqCz3BeRswKLuDJqdzMQlgdDZi9F3hFZPIbxgVM'
    stackexchange:
      clientID: '1451'
      clientSecret: 'CCkJpq3BY3e)lZFNsgkCkA(('
      key: 'dTtlx1WL0TJvOKPfoU88yg(('
    hipChat:
      tokens: {}

  test:
    defaults: defaults
    airconf:
      chat:
        firebasePath: 'https://airconf.firebaseio.com/chat/'
        firebaseSecret: 'PHQmJ3cVtcvdsWkb76fKTvIagbM5Ut1KFrDzSLmw'
    env: 'test'
    isProd: false
    mongoUri: process.env.MONGOHQ_URL || "mongodb://localhost/airpair_test"
    oauthHost: 'http://localhost:4444'
    analytics:
      segmentio:
        writeKey: 'test'
        settings: { flushAt: 1 }
      mixpanel:
        key: 'test'
        secret: 'test'
    mail:
      ses_access_key: 'test'
      ses_secret_key: 'test'
    mailchimp:
      apiKey: 'testing'
      airconfListId: 'testing'
    payment:
      stripe:
        publishedKey: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'
        secretKey:    'sk_test_8WOe71OlRWPyB3rDRcnthSCc'
      paypal:
        endpoint: 'https://svcs.sandbox.paypal.com/AdaptivePayments'
        primaryReceiver: 'jk-facilitator@airpair.com'
        SECURITYUSERID: 'jk-facilitator_api1.airpair.com',
        SECURITYPASSWORD: '1372567697',
        SECURITYSIGNATURE: 'An5ns1Kso7MWUdW4ErQKJJJ4qi4-AC6a0z5no3hrQwQyUMvBCahLxwBA'
        APPLICATIONID: 'APP-80W284485P519543T'
    google:
      passport:
        clientID: 'TEST'
        clientSecret: 'TEST'
      oauth:
        CLIENT_ID: "TEST"
        CLIENT_SECRET: "TEST"
        REDIRECT_URL: "http://localhost:444/oauth2callback"
      calendar:
        account: 'experts@airpair.com'
        params:
          calendarId: 'experts@airpair.com'
    linkedin:
      consumerKey: 'TEST'
      consumerSecret: 'TEST'
    bitbucket:
      consumerKey: 'TEST'
      consumerSecret: 'TEST'
    github:
      clientID: 'TEST'
      clientSecret: 'TEST'
    twitter:
      consumerKey: 'TEST'
      consumerSecret: 'TEST'
    stackexchange:
      clientID: 'TEST'
      clientSecret: 'TEST'
      key: 'TEST'
    hipChat:
      tokens: {}

  staging:
    defaults: defaults
    airconf:
      chat:
        firebasePath: 'https://airconf.firebaseio.com/chat/'
        firebaseSecret: 'PHQmJ3cVtcvdsWkb76fKTvIagbM5Ut1KFrDzSLmw'
    env: 'staging'
    isProd: false
    mongoUri: process.env.MONGOHQ_URL || "mongodb://localhost/airpair_staging"
    oauthHost: process.env.oauthHost || 'http://staging.airpair.com'
    analytics:
      segmentio:
        writeKey: process.env.SEGMENT_IO_WRITE_KEY
      mixpanel:
        key: 'e40b4a20aa555755d9b5d54936ae9cc0'
        secret: '3deb74f760d5ebf5ea418419f437cfc6'
    mail:
      ses_access_key: process.env.AP_SES_ACCESS_KEY || "none"
      ses_secret_key: process.env.AP_SES_SECRET_KEY || "none"
    mailchimp:
      apiKey: 'b888ee9284cd0d57f425867c0bde3fe0-us7'
      airconfListId: '39f4769300'
    payment:
      stripe:
        publishedKey: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'
        secretKey:    'sk_test_8WOe71OlRWPyB3rDRcnthSCc'
      paypal:
        endpoint: 'https://svcs.sandbox.paypal.com/AdaptivePayments'
        primaryReceiver: 'jk-facilitator@airpair.com'
        SECURITYUSERID: 'jk-facilitator_api1.airpair.com',
        SECURITYPASSWORD: '1372567697',
        SECURITYSIGNATURE: 'An5ns1Kso7MWUdW4ErQKJJJ4qi4-AC6a0z5no3hrQwQyUMvBCahLxwBA'
        APPLICATIONID: 'APP-80W284485P519543T'
    google:
      passport:
        clientID: '980673476043-cuf282ecpil53odvov4jlt1nb425vm4v.apps.googleusercontent.com'
        clientSecret: 'GfHNIzfDZrZPdeowpvcnMumK'
      oauth:
        CLIENT_ID: "980673476043-qo125e4cghau62thkrb4igkm50a1rp0l.apps.googleusercontent.com"
        CLIENT_SECRET: "T3OP1W-LjcdiS_cg8Ib8bBsc"
        REDIRECT_URL: "https://www.airpair.com/oauth2callback"
      calendar:
        account: 'experts@airpair.com'
        params:
          calendarId: 'experts@airpair.com' # experts@ primary calendar ID
    linkedin:
      consumerKey: 'rgd74pv5o45c'
      consumerSecret: 'd6fTF24fLvDe51zf'
    bitbucket:
      consumerKey: 'rgd74pv5o45c'  #linkedIN api key
      consumerSecret: 'd6fTF24fLvDe51zf' #linkedIn secret key
    github:
      clientID: 'e4917fcf822c02fd04f6'
      clientSecret: '14292d0a3f665f73dde448fc90ff6c402ab6da9b'
    twitter:
      consumerKey: 'hzcDmWTPJZFooDh6r0v9A'
      consumerSecret: 'NwA4bJc6RFAGeSbpYwuEX0CdiTuoDj3qzyXj9uCQNs'
    stackexchange:
      clientID: '1489'
      clientSecret: '4cwYFL7O*I9xrmFm6wmGYQ(('
      key: 'tfYVUqc1*XmoIgqvCZH3Gg(('
    hipChat:
      tokens: {}

  prod:
    defaults: defaults
    airconf:
      chat:
        firebasePath: 'https://airpair-chat.firebaseio.com/chat/'
        firebaseSecret: 'xEJfxuGTt6HnvdX56jWlVZlZkHdE2czmtUvs33xD'
    env: 'prod'
    isProd: true
    mongoUri: process.env.MONGOHQ_URL || "mongodb://localhost/airpair_prod"
    oauthHost: 'https://www.airpair.com' # note https
    analytics:
      segmentio:
        writeKey: process.env.SEGMENT_IO_WRITE_KEY
      mixpanel:
        key: '700fdc0126f37c4a5b22666f92be6be3'
        secret: '468ef07fb0edeb07c1c47be0269e3f6f'
    mail:
      ses_access_key: process.env.AP_SES_ACCESS_KEY
      ses_secret_key: process.env.AP_SES_SECRET_KEY
    mailchimp:
      apiKey: 'b888ee9284cd0d57f425867c0bde3fe0-us7'
      airconfListId: '39f4769300'
    payment:
      stripe:
        publishedKey: 'pk_live_FEGruKDm6OZyagTHqhXWvV8G'
        secretKey:    'sk_live_ei0Duv3MIp56TzPYPSK2XWWf'
      paypal:
        endpoint: 'https://svcs.paypal.com/AdaptivePayments'
        primaryReceiver: 'jk@airpair.com'
        SECURITYUSERID: 'jk_api1.airpair.com',
        SECURITYPASSWORD: 'CKGLTLST5C2KYCXQ',
        SECURITYSIGNATURE: 'AFcWxV21C7fd0v3bYYYRCpSSRl31AQ3FdahDmrAydOM0v6NUkwsQ2Nug'
        APPLICATIONID: 'APP-7AK038815Y6144228'
    google:
      passport:
        clientID: '140030887085-c7ffv2q96gc56ejmnbpsp433anvqaukf.apps.googleusercontent.com'
        clientSecret: '1iB16yFbTgF4iJ3kB7C1lUwj'
      oauth:
        CLIENT_ID: "980673476043-qo125e4cghau62thkrb4igkm50a1rp0l.apps.googleusercontent.com"
        CLIENT_SECRET: "T3OP1W-LjcdiS_cg8Ib8bBsc"
        REDIRECT_URL: "https://www.airpair.com/oauth2callback"
      calendar:
        account: 'team@airpair.com'
        params:
          calendarId: 'airpair.co_19t01n0gd6g7548k38pd3m5bm0@group.calendar.google.com'
    linkedin:
      consumerKey: 'sy5n2q8o2i49'
      consumerSecret: 'lcKjdbFSNG3HfZsd'
    bitbucket:
      consumerKey: 'WpdhX5mWW4wmLuDPwA'
      consumerSecret: 'uZveS97GysRW6EzjfQhERSB2SpkyBeSJ'
    github:
      clientID: '5adb6a29c586908f8161'
      clientSecret: 'c4182b3402aa93dd6465e99ca90f2650a0596997'
    twitter:
      consumerKey: '8eIvjnVbj0BkMiUVQP0ZQ'
      consumerSecret: 'OwrnjqCz3BeRswKLuDJqdzMQlgdDZi9F3hFZPIbxgVM'
    stackexchange:
      clientID: '1432'
      clientSecret: 'oA5O0hVgWg3muObSVC8mSQ(('
      key: 'h0fVRSYpv0*MAKD7HXj5bw(('
    hipChat:
      tokens:
        jk: '6JoPYqdFoAaX1oFaf30Y2JA40uQkuiq3jWksQejU'
        il: 'PGtSa73sSh5sYYmGvX7ZNLxtnlVaSvlSQ5rE0SqB'
        pg: 'rEoSqeUhfbRdXkfSbzcAEkVqfrDq62Lvr7bicVjz'
        mc: 'cGMZmzxfV34nSVrnKVVgoEtD2vzZ9ooX9w8q5aMR'
