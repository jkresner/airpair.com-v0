module.exports = ->

  (req, res, next) ->

    # check for JK
    if req.user.googleId != '117132380360243205600'
      return res.send(403, {})

    next()