class FeedbackApi extends require('./_api')

  Svc: require('./../services/feedback')

  routes: (app) ->
    app.post  "/feedback", @ap, @sendMail

  sendMail: (req) => @svc.sendMail @data, req.originalUrl, @cbSend


module.exports = (app) -> new FeedbackApi(app)
