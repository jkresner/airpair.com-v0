NotificationSettingsController = ($rootScope, $scope, Expert) ->
  $scope.hourRange = _.map(new Array(20), (a, i) -> (i+1).toString())

  Expert.get()

  $rootScope.$on 'event:expert-fetched', =>
    $scope.expert = $rootScope.expert
    $scope.helper = new Helper($rootScope.expert)

  class Helper

    data = {}

    constructor: (expert) ->
      data.expert = expert
      @initializeTags()
      # angular needs a date object for date input
      data.expert.busyUntil = new Date(data.expert.busyUntil)

      values = [10, 40, 70, 110, 160, 230]
      movePublicRateTag = (index) =>
        $(".slider-col .tag").css('margin-left', "#{values.indexOf(parseInt(index)) * 20}%")
      $(".hourly .slider").noUiSlider
        start: [ 3, 4 ]
        step: 1
        margin: 0
        connect: true
        direction: "ltr"
        orientation: "horizontal"
        behaviour: "tap-drag"
        range:
          min: 0
          max: 5
        serialization:
          format:
            decimals: 0
            encoder: (value) ->
              values[value]

      $('.hourly .slider').val([values.indexOf(data.expert.minRate), values.indexOf(data.expert.rate)])
      movePublicRateTag(data.expert.rate)

      $('.hourly .slider').change (event, value) =>
        movePublicRateTag(value[1])
        data.expert.minRate = value[0]
        data.expert.rate = value[1]
        @update()



    updatedAt: ->
      moment(data.expert.updatedAt).fromNow()

    status: (value) ->
      if value?
        data.expert.status = if value then "ready" else "busy"
        data.expert.availability = ""
      data.expert.status == "ready"

    toggleStatus: () ->
      data.expert.availability = ""
      @status(!@status())
      @update()

    tagHasLevel: (tag, level) ->
      _.include(tag.levels, level)

    update: ->
      data.expert.updatedAt = new Date
      data.expert.save()

    initializeTags: ->
      _.each data.expert.tags, (tag) =>
        tag.levelBeginner = @tagGetterSetter(tag, 'beginner')
        tag.levelIntermediate = @tagGetterSetter(tag, 'intermediate')
        tag.levelExpert = @tagGetterSetter(tag, 'expert')
        tag.levelAny = ->
          tag.levelBeginner() || tag.levelIntermediate() || tag.levelExpert()
        tag.levelAll = ->
          tag.levelBeginner() && tag.levelIntermediate() && tag.levelExpert()
        tag.toggleTagLevels = =>
          value = !tag.levelAll()
          tag.levelBeginner(value)
          tag.levelIntermediate(value)
          tag.levelExpert(value)
          @update()

    tagGetterSetter: (tag, level) ->
      (value) ->
        if value?
          if value
            _.include(tag.levels, level) || tag.levels.push(level)
          else
            tag.levels = _.without(tag.levels, level)
        else
          _.include(tag.levels, level)

angular
  .module('ngAirPair')
  .controller('NotificationSettingsController', ['$rootScope', '$scope', 'Expert', NotificationSettingsController])
