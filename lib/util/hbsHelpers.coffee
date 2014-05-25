{tagsString}   = require '../mix/tags'

module.exports =
  register: (hbs) ->

    hbs.registerHelper 'JSON', (o) ->
      # $log 'JSON.safe', JSON.stringify(o), hbs.handlebars.SafeString
      new hbs.handlebars.SafeString(o+':'+JSON.stringify @[o])

    hbs.registerHelper 'tagsString', (tags, n) ->
      tagsString tags, n
