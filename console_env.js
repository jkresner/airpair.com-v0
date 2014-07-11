require("coffee-script");
require('./lib/util/globals');
global.mongoose = require('./app_mongoose')();
models = require('./lib/models/index');
for(key in models) {
  global[key] = models[key];
}
repl = require("repl")
r = repl.start("node> ")
