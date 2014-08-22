ngExpert = ($location, Restangular, Expert) ->
  ExpertModel = ->
    self: ->
      @

    init: ->
      @initializeTags()
      # angular needs a date object for date input
      @busyUntil = new Date(@busyUntil)

    updated: =>
      moment(@updatedAt).fromNow()

    isReady: (value) =>
      if value?
        @status = if value then "ready" else "busy"
        @availability = ""
      @status == "ready"

    tagHasLevel: (tag, level) =>
      _.include(tag.levels, level)

    initializeTags: =>
      _.each @tags, (tag) =>
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

    tagGetterSetter: (tag, level) =>
      (value) ->
        if value?
          if value
            _.include(tag.levels, level) || tag.levels.push(level)
          else
            tag.levels = _.without(tag.levels, level)
        else
          _.include(tag.levels, level)

    toggleStatus: =>
      @availability = ""
      @isReady(!@isReady())
      @update()

    update: =>
      @updatedAt = new Date
      @timezone = new Date().toString().substring(25, 45)
      # using Restangular $object loses scope
      # so create a copy before saving
      Restangular.copy(@).save()

  response = { exists: true }
  Expert.get('me').then (expert) ->
    if expert.name?
      # bind our model to the promise object. Magic!
      model = _.bind(ExpertModel, response)
      _.extend(response, expert, model().self())
      response.init()
    else
      _.extend(response, { exists: null })
      # redirect to be an expert if the user is not an expert
      $location.path("/settings/expert")
  response

angular
  .module('ngAirPair')
  .factory('CurrentExpert', ['$location', 'Restangular', 'Expert', ngExpert])
