(function() {
  var app, express;

  console.log("in app.coffee");

  express = require('express');

  app = express();

  app.get('/', function(req, res) {
    return res.redirect("http://codereview.airpair.co/");
  });

  app.get('/index', function(req, res) {
    return res.sendfile('./public/index.html');
  });

  app.get('/admin', function(req, res) {
    return res.sendfile('./public/admin.html');
  });

  app.get('/become-an-expert', function(req, res) {
    return res.sendfile('./public/beexpert.html');
  });

  app.use(express["static"](__dirname + '/public'));

  exports.startServer = function(port, path, callback) {
    var p;
    p = process.env.PORT || port;
    console.log("startServer on port: " + p + ", path " + path);
    return app.listen(p);
  };

}).call(this);