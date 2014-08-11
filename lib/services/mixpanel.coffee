crypto = require('crypto')

class Mixpanel
  user: (email, callback) ->
    params =
      api_key: config.analytics.mixpanel.key
      expire: moment().add('days', 1).unix()
      where: "properties[\"$email\"] == \"#{email}\""
    md5sum = crypto.createHash('md5')
    reducedParams = _.reduce params, (memo, value, key) ->
      "#{memo}#{key}=#{value}"
    , ""
    md5sum.update( reducedParams + config.analytics.mixpanel.secret)
    params.sig = md5sum.digest('hex')
    restler.get("http://mixpanel.com/api/2.0/engage/", {query: params})
      .on('success',  (data) -> callback(null, data))
      .on('error', (error, response) -> callback(error, null))
      .on('fail', (data, response) -> callback(response, null))

  addProperties: (email, object, callback) ->
    @user email, (error, response) =>
      if response? && _.some(response, response.results)
        object.mixpanel = response.results[0]?.$properties
      callback(error, object)

module.exports = new Mixpanel()
