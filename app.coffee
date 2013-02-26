console.log "in app node file"

express = require 'express'
app = express()

app.get '/', (req, res) -> res.sendfile './public/index.html'
app.get '/about', (req, res) -> res.sendfile './public/index.html'
app.get '/admin', (req, res) -> res.sendfile './public/admin.html'
app.get '/review', (req, res) -> res.sendfile './public/review.html'
app.get '/be-an-expert', (req, res) -> res.sendfile './public/beexpert.html'
app.get '/become-an-expert', (req, res) -> res.sendfile './public/beexpert.html'
app.get '/find-an-expert', (req, res) -> res.sendfile './public/findexpert.html'

app.use(express.static __dirname+'/public')


exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port

  console.log "startServer on port: #{p}, path #{path}"

  app.listen p