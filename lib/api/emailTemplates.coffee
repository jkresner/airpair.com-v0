class EmailTemplatesApi extends require('./_api')

  Svc: require './../services/emailTemplates'

  routes: (app) ->
    app.post "/emailTemplates", @loggedIn, @admin, @ap, @createOrUpdate

  createOrUpdate: (req, res, next) =>
    @svc.createOrUpdate(@data, @cbSend)

module.exports = (app) -> new EmailTemplatesApi(app)
