ExpertSettingsController = ($rootScope, $scope, Session) ->
  $scope.socialTypes = [
    'github'
    'stackoverflow'
    'bitbucket'
    'linkedin'
    'twitter'
  ]
  $scope.user = Session.data.user
  console.log Session.data.user
  $scope.allowContinue = ->
    $scope.user.github? || $scope.user.bitbucket? || $scope.user.twitter?

angular
  .module('ngAirPair')
  .controller('ExpertSettingsController', ['$rootScope', '$scope', 'Session', ExpertSettingsController])
