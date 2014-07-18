module.exports = (app) ->
  window.app.controller('headerController', ['$scope', '$firebase', 'global'
    ($scope, $firebase, global) ->
      $scope.global = global
      $scope.chatOut = ""
      $scope.chats = {}

      roomName = "main"
      ref = new Firebase("https://airpair-chat.firebaseio.com")
      chatRef = ref.child("room/#{roomName}")
      $firebase(chatRef).$bind($scope, 'chats')

      $scope.sendMessage = ->
        if $scope.chatOut.length > 0
          message = { name: global.name, message: $scope.chatOut }
          chatRef.push(message)
          $scope.chatOut = ""
  ])
