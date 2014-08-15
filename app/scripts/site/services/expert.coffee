ngExpert = ($rootScope, Restangular) ->
  class Expert
    constructor: ->
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

  Restangular.extendModel 'experts', (model) ->
    angular.extend(model, new Expert())

  restangular = Restangular.service('experts')
  get: (id) =>
    restangular.one(id).get()

angular
  .module('ngAirPair')
  .factory('Expert', ['$rootScope', 'Restangular', ngExpert])
