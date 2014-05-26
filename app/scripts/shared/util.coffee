exports = {}

exports.storage = (k, v) ->
  if !window.localStorage then return
  if typeof v == 'undefined' then return localStorage[k]
  localStorage[k] = v
  v

module.exports = exports
