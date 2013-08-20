ses =        require './ses'
async =       require 'async'
fs =          require 'fs'
handlebars =  require 'handlebars'

renderHandlebars = (data, templatePath, callback) ->
  fs.readFile templatePath, "utf-8", (error, templateData) ->
    return callback error if error
    templateFn = handlebars.compile templateData
    rendered = templateFn data
    callback null, rendered

renderEmail = (d, templateName, callback) ->
  htmlPath = "#{__dirname}/templates/#{templateName}.html.hbs"
  txtPath = "#{__dirname}/templates/#{templateName}.txt.hbs"
  async.parallel {
    Html: async.apply renderHandlebars, d, htmlPath
    Text: async.apply renderHandlebars, d, txtPath
  }, (error, results) -> callback(error, results)


sendEmail = (options) ->
  renderEmail(options, options.templateName, (e, rendered) ->
    rendered.Subject = options.subject
    ses.send(options.to, rendered, options.callback)
  )

sendEmailToAdmins = (options) ->
  options.to = ['maksim.ioffe@airpair.com', 'jk@airpair.com', 'l@lucasvo.com']
  sendEmail(options)

expertReviewRequest = (data) ->
  renderEmail data, "expertReviewRequest", (err, rendered) ->
    rendered.Subject = "Request this!"
    $log 'expertReviewRequest.rendered', rendered

    #@bug eventually: req.user.google._json.email
    ses.send "jk@airpair.com", rendered, ->

module.exports = {expertReviewRequest, sendEmail, sendEmailToAdmins}
