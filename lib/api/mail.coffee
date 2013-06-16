authz     = require './../identity/authz'
loggedIn  = authz.LoggedIn isApi:true
admin     = authz.Admin isApi:true


mailSend =    require './../mail/mailman'



class MailApi

  constructor: (app) ->
    app.post     "/api/adm/mail/expert-review", loggedIn, @expertReview


  expertReview: (req, res) =>

    emailData = { _id, expertName, companyName, adminName } = req.body

    $log 'emailData', emailData

    mailSend.expertReviewRequest emailData

    res.send 200



module.exports = (app) -> new MailApi(app)