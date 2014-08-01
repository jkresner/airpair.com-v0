ChatController = ($scope, $firebase, session) ->
  ref = new Firebase('https://airpair-chat.firebaseio.com/chat');

  $scope.messages = $firebase(ref.limit(15))
  $scope.username = session.name()

  $scope.addMessage = ->
    console.log "addMessage called"
    $scope.messages.$add
      from: $scope.username, content: $scope.message

    $scope.message = ""

angular
  .module('ngAirPair')
  .controller('ChatController', ['$scope', '$firebase', 'Session', ChatController])
