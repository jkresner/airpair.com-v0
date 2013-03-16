 var api_devs, api_skills, app, db, express, flushDb, mongoUri, mongoose;

  console.log("in app node file", process.cwd());

  mongoose = require('mongoose');

  express = require('express');

  app = express();

  app.configure(function() {
    app.use(express["static"](__dirname + '/public'));
    return app.use(express.bodyParser());
  });

  api_devs = require('./api/devs.coffee');

  api_skills = require('./api/skills.coffee');

  flushDb = false;

  if (flushDb) {
    api_devs.clear();
    api_skills.clear();
    api_skills.boot(api_devs.boot);
  }

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

  app.get('/api/devs', api_devs.list);

  app.get('/api/devs:name', api_devs.show);

  app.post('/api/devs', api_devs.post);

  app.get('/api/skills', api_skills.list);

  app.get('/api/skills:id', api_skills.show);

  app.post('/api/skills', api_skills.post);

  mongoUri = process.env.MONGOHQ_URL || 'mongodb://localhost/airpair_dev';

  mongoose.connect(mongoUri);

  db = mongoose.connection;

  db.on('error', console.error.bind(console, 'connection error:'));

  db.once('open', function() {
    return console.log('connected to db airpair_dev');
  });

p = process.env.PORT || 500;
console.log("startServer on port: " + p);
app.listen(p);