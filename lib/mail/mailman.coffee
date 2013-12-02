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

class Mailman
  renderEmail: (d, templateName, callback) ->
    htmlPath = "#{__dirname}/templates/#{templateName}.html.hbs"
    txtPath = "#{__dirname}/templates/#{templateName}.txt.hbs"
    async.parallel {
      Html: async.apply renderHandlebars, d, htmlPath
      Text: async.apply renderHandlebars, d, txtPath
    }, (error, results) -> callback(error, results)

  # TODO change call signature to `options, callback`. And test everything.
  sendEmail: (options) =>
    @renderEmail(options, options.templateName, (e, rendered) ->
      rendered.Subject = options.subject
      ses.send(options.to, rendered, options.callback)
    )

  sendEmailToAdmins: (options) ->
    options.to = ['mi@airpair.com', 'jk@airpair.com', 'il@airpair.com',
      'dt@airpair.com']
    @sendEmail(options)

  importantRequestEvent: (options, callback) ->
    if !callback then callback = (e) ->
      if e then return console.log e.stack

    ### what we need
    owner
    user: user.google.displayName || 'anon'
    expertStatus
    evtName
    request._id
    callback
    ###

    options.user = options.user || 'anon'

    if !options.owner then return callback()
    options.templateName = 'importantRequestEvent'
    options.to = "#{options.owner}@airpair.com"
    options.subject = "[#{options.owner}] '#{options.evtName}' triggered by #{options.user}"
    options.callback = callback
    @sendEmail(options)

  expertReviewRequest: (data, callback) ->
    @renderEmail data, "expertReviewRequest", (err, rendered) ->
      if err then return callback err

      rendered.Subject = "Request this!"
      $log 'expertReviewRequest.rendered', rendered

      #@bug eventually: req.user.google._json.email
      ses.send "jk@airpair.com", rendered, callback

module.exports = new Mailman()
