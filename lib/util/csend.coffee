module.exports = cSend = (res, next) ->
  (e, r) ->
    if e && e.status then return res.send(400, e) # backbone will render errors
    if e then return next e
    res.send r
