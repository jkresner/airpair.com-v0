ExpertSettingsController = ($rootScope, $scope, $timeout, Session, CurrentExpert, Tag) ->
  $scope.user = Session.data.user
  $scope.session = Session

  $scope.hourRange = _.map(new Array(20), (a, i) -> (i+1).toString())
  $scope.rates = [10, 40, 70, 110, 160, 230]
  $scope.socialTypes = [
    'github'
    'stackexchange'
    'bitbucket'
    'linkedin'
    'twitter'
  ]
  $scope.socialClass = (type) ->
    if type == "stackexchange" then "stackoverflow" else type

  $scope.hasSocialKey = (type) ->
    newType = _.clone(type)
    if type == "stackexchange" then newType = "stack"
    $scope.user[newType]?

  $scope.tagOptions =
    multiple: true
    formatNoMatches: 'No technology found'

  expertTagList = []
  setExpertTagList = (values) =>
    # angular getters and setters require
    # that the same object be returned
    expertTagList.length = 0
    expertTagList.push value for value in values

  $scope.alert = { show: false, message: "" }
  $scope.showAlert = (message) =>
    $scope.alert.show = true
    $scope.alert.message = message
    $timeout =>
      $scope.alert.show = false
      $scope.alert.message = ""
    , 2000

  $scope.updateExpert = ->
    $scope.expert.update()
    $scope.showAlert("Settings saved.")

  $scope.myTags = (values) =>
    if values? && $scope.expert?
      $scope.expert.tags = _.map values, (value) =>
        existingTag = _.find $scope.expert.tags, (tag) =>
          tag._id == value
        existingLevels = existingTag?.levels || ['beginner', 'intermediate', 'expert']
        _.merge($scope.tags[value], levels: existingLevels)
      setExpertTagList(values)
    expertTagList

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

angular
  .module('ngAirPair')
  .controller('ExpertSettingsController', ['$rootScope', '$scope', '$timeout', 'Session', 'CurrentExpert', 'Tag', ExpertSettingsController])
