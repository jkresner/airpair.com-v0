var api_devs, api_skills, app, db, express, flushDb, mongoUri, mongoose;

mongoose = require('mongoose');

express = require('express');

app = express();

app.configure(function() {
  app.use(express["static"](__dirname + '/public'));
  return app.use(express.bodyParser());
});

api_devs = require('./app/api/devs');

api_skills = require('./app/api/skills');

app.get('/', function(req, res) {
  return res.sendfile('./public/index.html');
});

app.get('/about', function(req, res) {
  return res.sendfile('./public/index.html');
});

app.get('/admin', function(req, res) {
  return res.sendfile('./public/admin.html');
});

app.get('/review', function(req, res) {
  return res.sendfile('./public/review.html');
});

app.get('/be-an-expert', function(req, res) {
  return res.sendfile('./public/beexpert.html');
});

app.get('/become-an-expert', function(req, res) {
  return res.sendfile('./public/beexpert.html');
});

app.get('/find-an-expert', function(req, res) {
  return res.sendfile('./public/findexpert.html');
});

p = process.env.PORT || 500;
console.log("startServer on port: " + p);
app.listen(p);