# /* The API controller
#    Exports 3 methods:
#    * post - Creates a new thread
#    * list - Returns a list of threads
#    * show - Displays a thread and its posts
# */
Dev = require '../models/dev'


exports.clear = -> Dev.find({}).remove()


exports.post = (req, res) ->
    new Dev( name: req.body.name ).save()


exports.list = (req, res) ->
  Dev.find( (err, list) -> res.send list )


exports.show = (req, res) ->
  Dev.findOne { name: req.params.name }, (error, item) ->
    res.send item