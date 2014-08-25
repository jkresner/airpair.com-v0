mcapi = require('mailchimp-api')
Mixpanel = require('../services/mixpanel')

class Chimp

  API: new mcapi.Mailchimp(config.mailchimp.apiKey)

  # optionally pass a callback function
  subscribe: (data, mergeVars, cb) ->
    winston.error "Chimp.subscribeSilent: listId null" if !data.listId?
    getDistinctId = (result) =>
      if data.distinctId?
        console.log 'Chimp: passed a distinctId to track', data.distinctId
        @track(data.distinctId, data.listId)
        cb(null, result)
      else
        console.log 'Chimp: looking up a distinctId on Mixpanel by email', data.email
        Mixpanel.user data.email, (error, response) =>
          if response? && _.some(response.results)
            @track(response.results[0]['$distinct_id'], data.listId)
          cb(null, result)

    params =
      id: data.listId
      email: { email: data.email }
      merge_vars: mergeVars
      update_existing: true

    @API.lists.subscribe params, getDistinctId, @errorHandler(data.listId, data.email, mergeVars, cb)

  # optionally pass a callback function
  subscribeSilent: (listId, email, mergeVars, cb) ->
    winston.error "Chimp.subscribeSilent: listId null" if !listId?
    params =
      id: listId
      email: { email: email }
      merge_vars: mergeVars
      update_existing: true
      double_optin: false

    @API.lists.subscribe params, @successHandler(cb), @errorHandler(listId, email, mergeVars, cb)

  successHandler: (cb) ->
    (result) ->
      cb(null, result) if cb?

  errorHandler: (listId, email, mergeVars, cb) ->
    (err) ->
      if config.isProd
        winston.error "Chimp Problem: #{listId}, #{email}, #{mergeVars} #{err}"
      else
        $log "Chimp: subscribe failed !!!", listId, email, mergeVars, err
      cb(err) if cb?

  track: (mixpanelId, listId) ->
    segmentio.track
      userId: mixpanelId
      event: 'AddedToMailchimpList'
      properties: { listId }


module.exports = new Chimp()
