express = require 'express'
app = express()


app.get '/', (req, res) -> res.redirect "http://codereview.airpair.co/"
app.get '/index', (req, res) -> res.sendfile './public/index.html'
app.get '/admin', (req, res) -> res.sendfile './public/admin.html'
app.get '/become-an-expert', (req, res) -> res.sendfile './public/beexpert.html'


app.use(express.static __dirname+'/public')


exports.startServer = (port, path, callback) ->
  console.log "startServer on port: #{port}, path #{path}"

  app.listen port
  console.log "Listening on port: #{port}"