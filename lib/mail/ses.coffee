# Ses = require('awssum-amazon-ses').Ses

# ses = new Ses
#     accessKeyId     : config.mail.ses_access_key
#     secretAccessKey : config.mail.ses_secret_key

# emailDefaults =
#   #CcAddresses: []
#   #BccAddresses: []
#   TextCharset: 'UTF-8'
#   HtmlCharset: 'UTF-8'
#   SubjectCharset: 'UTF-8'
#   Source: 'jk@airpair.com'



send = (to, data, callback) ->
  callback()
  # if typeof to == 'string' then to = [to]
  # data.ToAddresses = to
  # # $log 'ses.send', to, data.Subject, data.Text
  # data = _.defaults(data, emailDefaults)
  # if config.env in ['test', 'dev']
  #   if callback? then callback()
  # else
  #   ses.SendEmail data, callback || (e) ->
  #     if e then $log e.stack


module.exports = { send }
