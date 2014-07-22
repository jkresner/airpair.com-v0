{tagsString}   = require '../mix/tags'


module.exports =
  register: (hbs) ->

    hbs.registerHelper 'JSON', (o) ->
      new hbs.handlebars.SafeString o+':'+JSON.stringify @[o]

    hbs.registerHelper 'tagsString', (tags, n) ->
      tagsString tags, n

    hbs.registerHelper 'isAdmin', ->
      Roles = require '../identity/roles'
      $log 'isAdmin', Roles, @session
      Roles.isAdmin(@session).toString()
