ExpertSettingsController = ($rootScope, $scope, Session, Expert, Tag) ->
  Expert.get()
  Tag.all()

  $scope.hourRange = _.map(new Array(20), (a, i) -> (i+1).toString())
  $scope.rates = [10, 40, 70, 110, 160, 230]
  $scope.socialTypes = [
    'github'
    'stackoverflow'
    'bitbucket'
    'linkedin'
    'twitter'
  ]
  $scope.tagOptions =
    multiple: true
    formatNoMatches: 'No technology found'

  expertTagList = []
  setExpertTagList = (values) =>
    # angular getters and setters require
    # that the same object be returned
    expertTagList.length = 0
    expertTagList.push value for value in values

  $scope.myTags = (values) =>
    if values? && $scope.expert?
      $scope.expert.tags = _.map values, (value) =>
        existingTag = _.find $scope.expert.tags, (tag) =>
          tag._id == value
        existingLevels = existingTag?.levels || ['beginner', 'intermediate', 'expert']
        _.merge($scope.tags[value], levels: existingLevels)
      setExpertTagList(values)
    expertTagList

  $scope.user = Session.data.user
  $scope.allowContinue = ->
    $scope.user.github? || $scope.user.bitbucket? || $scope.user.twitter?

  $rootScope.$on 'event:tags-fetched', =>
    # create a dictionary for faster lookup
    $scope.tags = _.reduce $rootScope.tags, (memo, tag) =>
      memo[tag._id] =
        _id: tag._id
        name: tag.name
        short: tag.short
        soId: tag.soId
      memo
    , {}

  $rootScope.$on 'event:expert-fetched', =>
    $scope.expert = $rootScope.expert
    $scope.helper = new Helper($scope.expert)
    setExpertTagList(_.pluck($scope.expert.tags, '_id'))

  class Helper
    constructor: (@expert) ->
    status: (value) ->
      if value?
        @expert.status = if value then "ready" else "busy"
        @expert.availability = ""
      @expert.status == "ready"

    toggleStatus: () ->
      @expert.availability = ""
      @status(!@status())
      @update()

    update: ->
      @expert.updatedAt = new Date
      @expert.save()

    updatedAt: ->
      moment(@expert.updatedAt).fromNow()

angular
  .module('ngAirPair')
  .controller('ExpertSettingsController', ['$rootScope', '$scope', 'Session', 'Expert', 'Tag', ExpertSettingsController])
