ExpertSettingsController = ($rootScope, $scope, Session, CurrentExpert, Tag) ->

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

  Tag.all().then (tags) =>
    # create a dictionary for faster lookup
    $scope.tags = _.reduce tags, (memo, tag) =>
      memo[tag._id] =
        _id: tag._id
        name: tag.name
        short: tag.short
        soId: tag.soId
      memo
    , {}
    setExpertTagList(_.pluck($scope.expert.tags, '_id'))

  $scope.expert = CurrentExpert
  $scope.update= =>
    $scope.expert.updatedAt = new Date
    $scope.expert.save()

  $scope.toggleStatus = () =>
    $scope.expert.availability = ""
    $scope.expert.isReady(!@isReady())


  window.expert = $scope.expert

angular
  .module('ngAirPair')
  .controller('ExpertSettingsController', ['$rootScope', '$scope', 'Session', 'CurrentExpert', 'Tag', ExpertSettingsController])
