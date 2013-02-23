console.log("in app node file");

express = require('express');

app = express();

app.get('/', function(req, res) {
  return res.redirect("http://codereview.airpair.co/");
});

app.get('/index', function(req, res) {
  return res.sendfile('./public/index.html');
});

app.get('/about', function(req, res) {
  return res.sendfile('./public/about.html');
});

app.get('/admin', function(req, res) {
  return res.sendfile('./public/admin.html');
});

app.get('/review', function(req, res) {
  return res.sendfile('./public/review.html');
});

app.get('/become-an-expert', function(req, res) {
  return res.sendfile('./public/beexpert.html');
});

app.use(express["static"](__dirname + '/public'));

p = process.env.PORT || 500;
console.log("startServer on port: " + p);
app.listen(p);