module.exports =
  dev:
    env: 'dev'
    mongoUri: process.env.MONGOHQ_URL || "mongodb://localhost/airpair_dev"
    oauthHost: 'http://localhost:3333'
    analytics:
      segmentio:
        writeKey: 'v8ltc907ww'
        settings: { flushAt: 1 }
    mail:
      ses_access_key: process.env.AP_SES_ACCESS_KEY
      ses_secret_key: process.env.AP_SES_SECRET_KEY
    payment:
      stripe:
        publishedKey: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'
        secretKey:    'sk_test_8WOe71OlRWPyB3rDRcnthSCc'
    google:
      oauth:
        CLIENT_ID: "980673476043-qo125e4cghau62thkrb4igkm50a1rp0l.apps.googleusercontent.com"
        CLIENT_SECRET: "T3OP1W-LjcdiS_cg8Ib8bBsc"
        REDIRECT_URL: "https://www.airpair.com/oauth2callback"
      calendar:
        account: 'experts@airpair.com'
        params:
          calendarId: 'experts@airpair.com' # experts@ primary calendar ID
    hipChat:
      tokens: {}

  test:
    env: 'test'
    mongoUri: process.env.MONGOHQ_URL || "mongodb://localhost/airpair_test"
    oauthHost: 'http://localhost:4444'
    analytics:
      segmentio:
        writeKey: 'test'
        settings: { flushAt: 1 }
    mail:
      ses_access_key: 'test'
      ses_secret_key: 'test'
    payment:
      stripe:
        publishedKey: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'
        secretKey:    'sk_test_8WOe71OlRWPyB3rDRcnthSCc'
    google:
      oauth:
        CLIENT_ID: "TEST"
        CLIENT_SECRET: "TEST"
        REDIRECT_URL: "http://localhost:444/oauth2callback"
      calendar:
        account: 'experts@airpair.com'
        params:
          calendarId: 'experts@airpair.com'
    hipChat:
      tokens: {}

  staging:
    env: 'staging'
    mongoUri: process.env.MONGOHQ_URL || "mongodb://localhost/airpair_staging"
    oauthHost: process.env.oauthHost || 'http://staging.airpair.com'
    analytics:
      segmentio:
        writeKey: 'v8ltc907ww'
    mail:
      ses_access_key: process.env.AP_SES_ACCESS_KEY
      ses_secret_key: process.env.AP_SES_SECRET_KEY
    payment:
      stripe:
        publishedKey: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'
        secretKey:    'sk_test_8WOe71OlRWPyB3rDRcnthSCc'
    google:
      oauth:
        CLIENT_ID: "980673476043-qo125e4cghau62thkrb4igkm50a1rp0l.apps.googleusercontent.com"
        CLIENT_SECRET: "T3OP1W-LjcdiS_cg8Ib8bBsc"
        REDIRECT_URL: "https://www.airpair.com/oauth2callback"
      calendar:
        account: 'experts@airpair.com'
        params:
          calendarId: 'experts@airpair.com' # experts@ primary calendar ID
    hipChat:
      tokens: {}

  prod:
    env: 'prod'
    isProd: true
    mongoUri: process.env.MONGOHQ_URL || "mongodb://localhost/airpair_prod"
    oauthHost: 'https://www.airpair.com' # note https
    analytics:
      segmentio:
        writeKey: 'v8ltc907ww'
    mail:
      ses_access_key: process.env.AP_SES_ACCESS_KEY
      ses_secret_key: process.env.AP_SES_SECRET_KEY
    payment:
      stripe:
        publishedKey: 'pk_live_FEGruKDm6OZyagTHqhXWvV8G'
        secretKey:    'sk_live_ei0Duv3MIp56TzPYPSK2XWWf'
    google:
      oauth:
        CLIENT_ID: "980673476043-qo125e4cghau62thkrb4igkm50a1rp0l.apps.googleusercontent.com"
        CLIENT_SECRET: "T3OP1W-LjcdiS_cg8Ib8bBsc"
        REDIRECT_URL: "https://www.airpair.com/oauth2callback"
      calendar:
        account: 'team@airpair.com'
        params:
          calendarId: 'airpair.co_19t01n0gd6g7548k38pd3m5bm0@group.calendar.google.com'
    hipChat:
      tokens:
        jk: '6JoPYqdFoAaX1oFaf30Y2JA40uQkuiq3jWksQejU'
        il: 'PGtSa73sSh5sYYmGvX7ZNLxtnlVaSvlSQ5rE0SqB'
        pg: 'rEoSqeUhfbRdXkfSbzcAEkVqfrDq62Lvr7bicVjz'
        of: 'VevT6jyRfFULfPKxPObntQf8aItMbF58n3yMjzCP'
        du: 'Aq0Iexi3xc13xjA3SMmrB4WBUT8n2WUZFPx3NLmz'
