mcapi = require('mailchimp-api');

class Chimp

  API: new mcapi.Mailchimp(config.mailchimp.apiKey)

  # optionally pass a callback function
  subscribe: (listId, email, mergeVars, cb) ->
    params =
      id: listId
      email: { email: email }
      merge_vars: mergeVars
      update_existing: true

    @API.lists.subscribe params, @successHandler(cb), @errorHandler(listId, email, mergeVars, cb)

  successHandler: (cb) ->
    (result) ->
      cb(null, result) if cb?

  errorHandler: (listId, email, mergeVars, cb) ->
    (err) ->
      if config.isProd
        winston.error "Chimp Problem: #{listId}, #{email}, #{updateExisting}, #{mergeVars} #{err}"
      else
        $log "Chimp: subscribe failed !!!", listId, email, mergeVars, err
      cb(err) if cb?

module.exports = new Chimp()
