module.exports = ->

  (req, res, next) ->

    if !req.isAuthenticated || !req.isAuthenticated()
      return res.redirect '/'

    # check for JK
    if req.user.googleId != '117132380360243205600'
      return res.redirect '/'

    next()