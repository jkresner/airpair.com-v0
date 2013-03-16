console.log "in app node file", process.cwd()

mongoose = require 'mongoose'
express = require 'express'
app = express()

app.configure ->
  app.use(express.static(__dirname + '/public'))
  app.use(express.bodyParser())

api_skills = require './api/skills'
api_devs = require './api/devs'
api_companys = require './api/companys'

flushDb = false
if flushDb
  console.log '***** flushing DB'
  api_devs.clear()
  api_companys.clear()
  api_skills.clear()
  api_skills.boot api_devs.boot


app.get  '/', (req, res) -> res.sendfile './public/index.html'
app.get  '/about', (req, res) -> res.sendfile './public/index.html'
app.get  '/adminn', (req, res) -> res.sendfile './public/admin.html'
app.get  '/review', (req, res) -> res.sendfile './public/review.html'
app.get  '/be-an-expert', (req, res) -> res.sendfile './public/beexpert.html'
app.get  '/become-an-expert', (req, res) -> res.sendfile './public/beexpert.html'
app.get  '/find-an-expert', (req, res) -> res.sendfile './public/findexpert.html'


app.get     '/api/devs', api_devs.list
app.get     '/api/devv/:id', api_devs.show
app.post    '/api/devs', api_devs.post
app.get     '/api/skills', api_skills.list
app.get     '/api/skills/:id', api_skills.show
app.post    '/api/skills', api_skills.post
app.get     '/api/companys', api_companys.list
app.get     '/api/companys/:id', api_companys.show
app.put     '/api/companys/:id', api_companys.update
app.delete  '/api/companys/:id', api_companys.delete
app.post    '/api/companys', api_companys.post



mongoUri = process.env.MONGOHQ_URL || 'mongodb://localhost/airpair_dev'

mongoose.connect mongoUri

db = mongoose.connection
db.on('error', console.error.bind(console, 'connection error:'))
db.once 'open', ->
  console.log 'connected to db airpair_dev'


exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port
  console.log "startServer on port: #{p}, path #{path}"
  app.listen p


isHeroku = process.env.MONGOHQ_URL?
if isHeroku
  exports.startServer()