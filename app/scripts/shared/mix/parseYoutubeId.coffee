parseYoutubeId = (str) ->
  str = str.trim()
  variable = '([a-zA-Z0-9_]*)'
  # e.g. http://www.youtube.com/watch?v=aANmpDSTcXI&otherjunkparams
  id = str.match("v=#{variable}")?[1]
  if id then return id

  # e.g. youtu.be/aANmpDSTcXI
  id = str.match("youtu\.be/#{variable}")?[1]
  if id then return id

  # e.g. aANmpDSTcXI
  str.match("^#{variable}$")?[1]

module.exports = parseYoutubeId
