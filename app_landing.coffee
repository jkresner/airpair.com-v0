ViewDataService = require('./lib/services/_viewdata')
vdSvc = new ViewDataService()

track = (pageName) =>
  (req, r, next) ->
    r.cookie 'landingPage', pageName
    next()

file = (r, file) -> r.sendfile "./public/#{file}.html"

# landing pages
module.exports = (app) ->

  app.get '/ruby-on-rails-tutoring', track('ruby-on-rails-tutoring'), (req, r) ->
    file r, 'landing_pages/ruby_on_rails_tutoring'

  app.get '/code-review', track('code-review'), (req, r) ->
    file r, 'landing_pages/codeReview'

  app.get '/code-review/:id', track('code-review/tag'), (req, r) ->
    vdSvc.codeReview req.params.id, req.user, (d) =>
      r.render 'landing_pages/codeReviewTag.html', d

  app.get '/pair-programming', (track 'pair-programming'), (req, r) ->
    file r, 'landing_pages/pairProgramming'