Ses = require('awssum-amazon-ses').Ses

ses = new Ses
    accessKeyId     : cfg.SES_ACCESS_KEY
    secretAccessKey : cfg.SES_SECRET_KEY

emailDefaults =
  #CcAddresses: []
  #BccAddresses: []
  TextCharset: 'UTF-8'
  HtmlCharset: 'UTF-8'
  SubjectCharset: 'UTF-8'
  Source: 'jk@airpair.com'



send = (to, data, callback) ->
  if typeof to == 'string' then to = [to]
  data.ToAddresses = to
  data = _.defaults(data, emailDefaults)
  if cfg.env is 'test' or cfg.env is 'dev'
    return callback()
  ses.SendEmail data, callback


module.exports = { send }
