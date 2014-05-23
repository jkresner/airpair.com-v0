module.exports = ObjectId2Date = (id) ->
  new Date(parseInt(id.toString().slice(0, 8), 16) * 1000)
