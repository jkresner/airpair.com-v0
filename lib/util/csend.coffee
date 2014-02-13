module.exports = cSend = (res, next) ->
  (e, r) ->
    if e then return next e
    res.send r
