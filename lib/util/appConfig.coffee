c = {}

# dev, test, staging, prod
# process.env.Env should be set in the environment
process.env.Env = brunch.env if !process.env.Env? && brunch?
c.env      = process.env.Env
c.isProd   = c.env is 'prod'

c.mongoUri = process.env.MONGOHQ_URL || "mongodb://localhost/airpair_#{c.env}"

c.analytics =
  mixpanel: { id: '836dbdc21253fa8f3a68657c2f5ec4f1' }

c.SES_ACCESS_KEY = process.env.AP_SES_ACCESS_KEY ? 'blah'
c.SES_SECRET_KEY = process.env.AP_SES_SECRET_KEY ? 'gah'

c.payment =
  stripe:
    publishedKey: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'
    secretKey:    'sk_test_8WOe71OlRWPyB3rDRcnthSCc'

c.oauthHost = 'http://localhost:3333'
c.google =
  oauth:
    CLIENT_ID: "980673476043-qo125e4cghau62thkrb4igkm50a1rp0l.apps.googleusercontent.com"
    CLIENT_SECRET: "T3OP1W-LjcdiS_cg8Ib8bBsc"
    REDIRECT_URL: "https://www.airpair.com/oauth2callback"
  calendar:
    account: 'experts@airpair.com'
    params:
      calendarId: 'experts@airpair.com' # experts@ primary calendar ID

c.hipChat = tokens: []
c.hipChat.tokens['jk'] = '6JoPYqdFoAaX1oFaf30Y2JA40uQkuiq3jWksQejU'
c.hipChat.tokens['il'] = 'PGtSa73sSh5sYYmGvX7ZNLxtnlVaSvlSQ5rE0SqB'
c.hipChat.tokens['pg'] = 'rEoSqeUhfbRdXkfSbzcAEkVqfrDq62Lvr7bicVjz'
c.hipChat.tokens['tb'] = ''
c.hipChat.tokens['lt'] = 'Eu7RFTEXS4DSXFPpg5vx5eopwx6CyTcvIQ7Pn3oG'

if c.env is 'test'
  process.env.Payment_Env = 'test'
  c.SES_ACCESS_KEY = 'test'
  c.SES_SECRET_KEY = 'test'
  c.oauthHost = 'http://localhost:4444'

if c.env is 'prod'
  c.analytics.mixpanel.id = '076cac7a822e2ca5422c38f8ab327d62'
  c.payment.stripe =
    publishedKey: 'pk_live_FEGruKDm6OZyagTHqhXWvV8G'
    secretKey:    'sk_live_qSxo06x8iwaYuIIw1Bkx7hsz'
  c.oauthHost = 'https://www.airpair.com' # note https
  c.google.calendar.account = 'team@airpair.com'
  c.google.calendar.params =
    # team@ Air Pairings Calendar
    calendarId: 'airpair.co_19t01n0gd6g7548k38pd3m5bm0@group.calendar.google.com'

# option to overwrite in staging etc.
c.oauthHost = process.env.oauthHost if process.env.oauthHost?

global.cfg = c

console.log 'config: ', require('util').inspect(cfg, depth: null)
console.log "--------------------------------------------------------"
