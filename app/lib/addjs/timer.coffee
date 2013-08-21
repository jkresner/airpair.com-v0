module.exports = class Timer

  constructor: (category, variable, opt_label) ->
    @category = category
    @variable = variable
    @label = if opt_label? then opt_label else undefined
    @

  start: ->
    @startTime = new Date().getTime()
    @

  end: ->
    @endTime = new Date().getTime()
    @

#   send: ->
#     timeSpent = @endTime - @startTime
#     window._gaq.pus h ['_trackTiming', @category, @variable,
# timeSpent, @label]
#     @

  timeSpent: ->
    if !@endTime? then @end()
    @endTime - @startTime