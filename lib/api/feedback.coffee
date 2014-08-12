class FeedbackApi extends require('./_api')

  Svc: require('./../services/feedback')

  routes: (app, route) ->
    app.post  "/api/#{route}", @ap, @sendMail

  sendMail: (req) => @svc.sendMail @data, req.originalUrl, @cbSend


module.exports = (app) -> new FeedbackApi app, 'feedback'
