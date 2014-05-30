
tagsStringNobraces = (tags,limit) ->
  t = tags
  return '' if !t? || t.length is 0
  return "#{t[0].name}" if t.length is 1

  if limit? && t.length > limit
    t = t.slice 0, limit

  i = 0
  ts = "#{t[0].name}"
  for i in [1..t.length-1]
    if i is t.length - 1
      ts += " and #{t[i].name}" # and instead of & to fix urls
    else
      ts += " #{t[i].name}"
  ts



exports.tagsString = (tags,limit,nobraces) ->
  if nobraces then return tagsStringNobraces tags, limit
  t = tags
  return '' if !t? || t.length is 0
  return "{#{t[0].name}}" if t.length is 1

  if limit? && t.length > limit
    t = t.slice 0, limit

  i = 0
  ts = "{#{t[0].name}}"
  for i in [1..t.length-1]
    if i is t.length - 1
      ts += " and {#{t[i].name}}" # and instead of & to fix urls
    else
      ts += " {#{t[i].name}}"

  ts


