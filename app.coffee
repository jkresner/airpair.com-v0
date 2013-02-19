console.log "in app node file"

express = require 'express'
app = express()

app.get '/', (req, res) -> res.redirect "http://codereview.airpair.co/"
app.get '/index', (req, res) -> res.sendfile './public/index.html'
app.get '/admin', (req, res) -> res.sendfile './public/admin.html'
app.get '/review', (req, res) -> res.sendfile './public/review.html'
app.get '/become-an-expert', (req, res) -> res.sendfile './public/beexpert.html'


app.use(express.static __dirname+'/public')


exports.startServer = (port, path, callback) ->
  p = process.env.PORT || port

  console.log "startServer on port: #{p}, path #{path}"

  app.listen p