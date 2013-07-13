Ses    = require('awssum-amazon-ses').Ses

# ses = new Ses
#     accessKeyId     : process.env.AP_SES_ACCESS_KEY
#     secretAccessKey : process.env.AP_SES_SECRET_KEY


emailDefaults =
  #CcAddresses: []
  #BccAddresses: []
  TextCharset: 'UTF-8'
  HtmlCharset: 'UTF-8'
  SubjectCharset: 'UTF-8'
  Source: 'jk@airpair.com'



send = (to, data, callback) ->
  callback()
  # data = und.defaults(data, emailDefaults)
  # data.ToAddresses = [to]
  # ses.SendEmail data, callback


module.exports = { send }