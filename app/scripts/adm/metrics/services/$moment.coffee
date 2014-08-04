

# Moment Service - For date logic
#----------------------------------------------

angular.module('AirpairAdmin').factory('$moment', () ->
  $moment =
    months: (start) ->
      months = []
      cur = moment()
      while cur.isAfter(start)
        months.push
          str: cur.format("MMM YY")
          start: cur.clone().startOf("month").toDate()
          end: cur.clone().endOf("month").toDate()
        cur = cur.subtract('months', 1)
      return months
    years: (start) ->
      years = []
      curYear = moment(new Date()).startOf("year")
      while curYear.isAfter(start)
        years.push
          str: curYear.format("YYYY")
          start: curYear.startOf("year").clone().toDate()
          end: curYear.endOf("year").clone().toDate()
        curYear = curYear.subtract('y', 1)
      return years

    getWeeks: (start, end = moment().endOf('month')) ->
      if not start
        start = moment().startOf('month').subtract("days", 1)
      else
        start = start.startOf("week").subtract("days", 1)

      weeks = []
      cur = moment(new Date()).startOf("week")
      while cur.isAfter(start)
        weeks.push
          str: cur.format("MMM D")
          start: cur.clone().toDate()
          end: cur.clone().endOf("week").toDate()
        cur = cur.subtract('weeks', 1)
      return weeks

    getWeeksByFriday: (start, end) ->

      if not start
        start = moment().startOf('month').subtract("days", 2)

      if not end
        end = moment()

      if start.day() < 6
        start.startOf("week").subtract("d", 1).startOf("day")
      else
        start.endOf("week").startOf("day")


      weeks = []

      cur = moment(new Date())
      if cur.day() < 6
        cur.startOf("week").subtract("d", 1).startOf("day")
      else
        cur.endOf("week").startOf("day")


      while cur.isAfter(start) or cur.isSame(start)
        if cur.isBefore(end) or cur.isSame(end)
          weeks.push
            str: cur.clone().add('w', 1).subtract('d', 1).format("MM DD")
            index: cur.format("YYMMDD")
            start: cur.toDate()
            end: cur.clone().add('w', 1).toDate()
        cur = cur.clone().subtract('w', 1)


      return weeks

    daysOfWeek: (weekStart) ->
      # console.log "weekStart", weekStart.toDate()
      dayStart = weekStart
      days = []
      for num in [0..6]
        day =
          start: dayStart.clone()
          end: dayStart.clone().endOf("day")
        days.push day
        dayStart = dayStart.add("d", 1)
        # console.log "START ", day.start.toDate(), "END", day.end.toDate()

      return days

)

