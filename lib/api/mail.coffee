authz = require './../auth/authz/isLoggedInApi'
admin = require './../auth/authz/isAdminApi'



mailSend =    require './../mail/mailman'



class MailApi

  constructor: (app) ->
    app.post     "/api/adm/mail/expert-review", authz(), @expertReview


  expertReview: (req, res) =>

    emailData = { _id, expertName, companyName, adminName } = req.body

    $log 'emailData', emailData

    mailSend.expertReviewRequest emailData

    res.send 200



module.exports = (app) -> new MailApi(app)