
tagsStringNobraces = (tags,limit) ->
  t = tags
  return '' if !t? || t.length is 0
  return "#{t[0].slug}" if t.length is 1

  if limit? && t.length > limit
    t = t.slice 0, limit

  i = 0
  ts = "#{t[0].slug}"
  for i in [1..t.length-1]
    if i is t.length - 1
      ts += " and #{t[i].slug}" # and instead of & to fix urls
    else
      ts += " #{t[i].slug}"
  ts



exports.tagsString = (tags,limit,nobraces) ->
  if nobraces then return tagsStringNobraces tags, limit
  t = tags
  return '' if !t? || t.length is 0
  return "{#{t[0].slug}}" if t.length is 1

  if limit? && t.length > limit
    t = t.slice 0, limit

  i = 0
  ts = "{#{t[0].slug}}"
  for i in [1..t.length-1]
    if i is t.length - 1
      ts += " and {#{t[i].slug}}" # and instead of & to fix urls
    else
      ts += " {#{t[i].slug}}"

  ts


