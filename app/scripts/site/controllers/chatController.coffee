ChatController = ($scope, $firebase, session) ->
  workshop = session.data.workshop

  # use slug to key the chat stream
  firebaseSlug = workshop.slug.replace(".", "")
  ref = new Firebase("https://airpair-chat.firebaseio.com/chat/#{firebaseSlug}")

  $scope.messages = $firebase(ref.limit(15))
  $scope.user = session.data.user.google._json

  $scope.addMessage = ->
    $scope.messages.$add
      from: $scope.user.name
      pic: $scope.user.picture
      content: $scope.message
      timestamp: new Date

    $scope.message = ""


angular
  .module('ngAirPair')
  .controller('ChatController', ['$scope', '$firebase', 'Session', ChatController])
