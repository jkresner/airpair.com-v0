exports = {}


exports.tagsString = (tags) ->
  t = tags
  return '' if !t? || t.length is 0
  return t[0].name if t.length is 1
  i = 0
  ts = t[0].name
  for i in [1..t.length-1]
    if i is t.length - 1
      ts += " and #{t[i].name}" # and instead of & to fix urls
    else
      ts += ", #{t[i].name}"
  ts

exports.storage = (k, v) ->
  if !window.localStorage then return
  if typeof v == 'undefined' then return localStorage[k]
  localStorage[k] = v
  v

module.exports = exports
