express = require 'express'
app = express()

# require('../lib/api/chat')(app)
# require('../lib/api/companys')(app)
# require('../lib/api/emailTemplates')(app)
# require('../lib/api/experts')(app)
# require('../lib/api/landingPage')(app)
# require('../lib/api/marketingtags')(app)
# require('../lib/api/matchers')(app)
require('../lib/api/orders')(app)
# require('../lib/api/paymethods')(app)
# require('../lib/api/requestCalls')(app)
# require('../lib/api/requests')(app)
require('../lib/api/session')(app)
# require('../lib/api/settings')(app)
# require('../lib/api/tags')(app)
# require('../lib/api/users')(app)
# require('../lib/api/videos')(app)
# require('../lib/api/workshops')(app)

module.exports = app
