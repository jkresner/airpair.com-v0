module.exports =

  getFieldError: (msg, attr, attrMsg) ->
    err = isServer: true, msg: msg + " failed", data: {}
    err.data[attr] = attrMsg
    err
