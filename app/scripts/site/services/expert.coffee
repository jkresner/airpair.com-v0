ngExpert = ($http, $rootScope, Restangular) ->
  class Expert

    data = {}

    initializeTags = ->
      _.each data.expert.tags, (tag) =>
        tag.levelBeginner = tagGetterSetter(tag, 'beginner')
        tag.levelIntermediate = tagGetterSetter(tag, 'intermediate')
        tag.levelExpert = tagGetterSetter(tag, 'expert')
        tag.levelAny = ->
          tag.levelBeginner() || tag.levelIntermediate() || tag.levelExpert()

    tagGetterSetter = (tag, level) ->
      (value) ->
        if value?
          if value
            _.include(tag.levels, level) || tag.levels.push(level)
          else
            tag.levels = _.without(tag.levels, level)
        else
          _.include(tag.levels, level)

    constructor: ->
      @fetchExpert()

    updatedAt: ->
      data.expert? && moment(data.expert.updatedAt).fromNow()

    fetchExpert: ->
      Restangular.one('experts', 'me').get().then (expert) =>
        data.expert = expert
        initializeTags()
        # hack for slider, not good form
        values = [10, 40, 70, 110, 160, 230]
        $('.hourly .slider').val([values.indexOf(@minRate()), values.indexOf(@rate())])
        $(".slider-col .tag").css('margin-left', "#{values.indexOf(@rate()) * 20}%")

    hoursAvailable: (value) ->
      if value?
        data.expert.hours = value.toString()
      data.expert? && data.expert.hours

    busyUntil: (value) ->
      if value?
        data.expert.busyUntil = value
      # horrible hack, but angular blows up if you return
      # a date object from a getter and the angular date
      # input requires a date object #itsabug
      data.expert? && $('#busyUntil').val(moment(data.expert.busyUntil).format("YYYY-MM-DD"))
      data.expert? && moment(data.expert.busyUntil).format()

    status: (value) ->
      if value?
        data.expert.status = if value then "ready" else "busy"
        data.expert.availability = ""
      data.expert? && data.expert.status == "ready"

    setRate: (min, max) ->
      @minRate(min)
      @rate(max)

    rate: (value) ->
      if value?
        data.expert.rate = value
      data.expert? && data.expert.rate

    minRate: (value) ->
      if value?
        data.expert.minRate = value
      data.expert? && data.expert.minRate

    tags: ->
      data.expert? && data.expert.tags

    tagHasLevel: (tag, level) ->
      _.include(tag.levels, level)

    availability: (value) ->
      if value?
        data.expert.availability = value
      data.expert? && data.expert.availability

    requestStats: ->
      responseRate: data.expert?.stats.responseRate
      requestCount: data.expert?.stats.requestCount

    orderStats: ->
      paidOrderCount: data.expert?.stats.paidOrderCount
      totalAmountReceived: data.expert?.stats.totalAmountReceived
      averagePerHour: data.expert?.stats.averagePerHour

    update: ->
      data.expert.updatedAt = new Date
      data.expert.save()

  new Expert

angular
  .module('ngAirPair')
  .factory('Expert', ['$http', '$rootScope', 'Restangular', ngExpert])
