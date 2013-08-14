urlParser = require('url')
ViewDataService = require('./lib/services/_viewdata')
vdSvc = new ViewDataService()

track = (pageName) =>
  (req, r, next) ->
    if !req.cookies.landingPage
      referrerHost = urlParser.parse(req.headers.referer).host if req.headers.referer

      if req.headers.referer is undefined or referrerHost != req.headers.host
        if req.params? && req.params.id?
          pageName += "/#{req.params.id}"
        r.cookie 'landingPage', pageName
    next()

file = (r, file) -> r.sendfile "./public/#{file}.html"

tagData = (req, r, next) ->
    vdSvc.landingTag req.params.id, req.user, (d) =>
      r.viewData = d
      next()

viewOrFile = (pageName) ->
  (req, r) ->
    if r.viewData.tag?
      r.render "landing/#{pageName}Tag.html", r.viewData
    else
      r.status(404)
      file r, "landing/#{pageName}"

# landing pages
module.exports = (app) ->

  # app.get '/ruby-on-rails-tutoring', track('ruby-on-rails-tutoring'), (req, r) ->
  #   file r, 'landing/ruby_on_rails_tutoring'

  app.get '/code-review', track('codeReview'), (req, r) ->
    file r, 'landing/codeReview'

  app.get '/code-review/:id', track('codeReview'), tagData,
    viewOrFile('codeReview')

  app.get '/pair-programming', track('pairProgramming'), (req, r) ->
    file r, 'landing/pairProgramming'

  app.get '/pair-programming/:id', track('pairProgramming'), tagData,
    viewOrFile('pairProgramming')

  app.get '/code-mentoring', track('codeMentoring'), (req, r) ->
    file r, 'landing/codeMentoring'

  app.get '/code-mentoring/:id', track('codeMentoring'), tagData,
    viewOrFile('codeMentoring')

  app.get '/problem-solving', track('problemSolving'), (req, r) ->
    file r, 'landing/problemSolving'

  app.get '/problem-solving/:id', track('problemSolving'), tagData,
    viewOrFile('problemSolving')
