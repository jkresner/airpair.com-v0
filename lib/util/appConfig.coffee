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
  c.oauthHost = 'https://www.airpair.com' #note https

# option to overwrite in staging etc.
c.oauthHost = process.env.oauthHost if process.env.oauthHost? 

global.cfg = c

console.log 'config: ', cfg
console.log "--------------------------------------------------------"