module.exports =

  throwFieldError: (res, msg, attr, attrMsg) ->
    err = msg: msg + " failed", data: {}
    err.data[attr] = attrMsg
    err
    res.send 400, err