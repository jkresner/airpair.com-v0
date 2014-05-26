module.exports =
sum = (list) ->
  add = (prev, cur) ->
    prev + cur
  list.reduce add, 0
