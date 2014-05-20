ses =         require './ses'
async =       require 'async'
fs =          require 'fs'
handlebars =  require 'handlebars'
roles =       require '../identity/roles'
util =        require '../../app/scripts/util'

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

  sendEmail: (options, callback) =>
    @renderEmail(options, options.templateName, (e, rendered) ->
      rendered.Subject = options.subject
      ses.send options.to, rendered, callback
    )

  sendEmailToAdmins: (options, callback) ->
    options.to = _.map roles.getAdminInitials(), (initials) -> "#{initials}@airpair.com"
    @sendEmail options, callback


  admNewRequest: (request) ->
    fullName = ''  #temporary until fix bookme flow
    if request.company? then fullName = request.company.contacts[0].fullName
    @sendEmailToAdmins
      templateName: "admNewRequest"
      subject: "New request: #{fullName} #{request.budget}$"
      request: request
      tags: request.tags.map((o) -> o.short).join(' ')
      (e) -> if e then $log 'admNewRequest error', e


  ###
    the options object should have these properties:
    owner
    user: user.google.displayName || 'anon'
    expertStatus # optional
    experts # optional

    evtName
    requestId: request._id
    customerName: request.company.contacts[0].fullName
    tags: request.tags
    suggested: request.suggested

    callback # this is created automatically for you
  ###
  importantRequestEvent: (evtName, usr, request, callback) ->
    if !request.owner? then return callback && callback()

    o =
      evtName: evtName
      user: (usr.google && usr.google.displayName) || 'anon'
      owner: request.owner
      requestId: request._id
      customerName: request.company.contacts[0].fullName
      tags: request.tags
      tagsString: util.tagsString(request.tags)
      suggested: request.suggested

    o.templateName = 'importantRequestEvent'
    o.to = "#{o.owner}@airpair.com"
    o.subject =
      "[#{o.owner}] #{o.user} [#{o.evtName}] #{o.tagsString} request by #{o.customerName}"

    @sendEmail o, callback


  expertReviewRequest: (data, callback) ->
    @renderEmail data, "expertReviewRequest", (err, rendered) ->
      if err then return callback err

      rendered.Subject = "Request this!"
      $log 'expertReviewRequest.rendered', rendered

      #@bug eventually: req.user.google._json.email
      ses.send "jk@airpair.com", rendered, callback

module.exports = new Mailman()
