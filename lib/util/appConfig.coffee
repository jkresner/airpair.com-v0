c = {}

# dev, test, staging, prod
# process.env.Env should be set in the environment
process.env.Env = brunch.env if !process.env.Env? && brunch?
c.env      = process.env.Env
c.isProd   = @env is 'prod'

c.mongoUri = process.env.MONGOHQ_URL || "mongodb://localhost/airpair_#{c.env}"

c.analytics =
  mixpanel: { id: '7689506d104a2280998971f50e121dcc' }

c.SES_ACCESS_KEY = process.env.AP_SES_ACCESS_KEY ? 'blah'
c.SES_SECRET_KEY = process.env.AP_SES_SECRET_KEY ? 'gah'

c.payment =
  stripe:
    publishedKey: 'pk_test_aj305u5jk2uN1hrDQWdH0eyl'
    secretKey:    'sk_test_8WOe71OlRWPyB3rDRcnthSCc'

if c.env is 'test'
  process.env.Payment_Env = 'test'
  c.SES_ACCESS_KEY = 'test'
  c.SES_SECRET_KEY = 'test'

if c.env is 'prod'
  c.analytics.mixpanel.id = '076cac7a822e2ca5422c38f8ab327d62'
  c.payment.stripe =
    publishedKey: 'pk_live_FEGruKDm6OZyagTHqhXWvV8G'
    secretKey:    'sk_live_qSxo06x8iwaYuIIw1Bkx7hszc'

global.cfg = c

console.log 'config: ', cfg
console.log "--------------------------------------------------------"