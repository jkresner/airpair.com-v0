require("coffee-script");
require('../lib/util/globals');
global.mongoose = require('../app_mongoose')();
models = {
  ApiConfig: require('../lib/models/ApiConfig'),
  Company: require('../lib/models/company'),
  Expert: require('../lib/models/expert'),
  MarketingTag: require('../lib/models/marketingtag'),
  Message: require('../lib/models/message'),
  Order: require('../lib/models/order'),
  PayMethod: require('../lib/models/payMethod'),
  Request: require('../lib/models/request'),
  Room: require('../lib/models/room'),
  Settings: require('../lib/models/settings'),
  Tag: require('../lib/models/tag'),
  User: require('../lib/models/user')
}

for(key in models) {
  global[key] = models[key];
}
repl = require("repl")
r = repl.start("node> ")
