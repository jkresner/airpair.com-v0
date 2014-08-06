ChatDirective = ($firebase, session) ->
  templateUrl: '/templates/shared/chat_template'

  scope:
    title: '@'  # string attr value passed in
    ngModel: '='  # bind by reference passed in

  restrict: 'E'

  ## ngModel should have a slug attribute
  link: (scope, element, attributes) ->
    if session.isSignedIn()
      # use slug to key the chat stream
      firebaseSlug = scope.ngModel.slug.replace(".", "")
      ref = new Firebase("https://airpair-chat.firebaseio.com/chat/#{firebaseSlug}")

      scope.messages = $firebase(ref.limit(15))
      scope.user = session.data.user.google._json

      scope.addMessage = ->
        scope.messages.$add
          from: scope.user.name
          pic: scope.user.picture
          content: scope.message
          timestamp: new Date

        scope.message = ""

angular
  .module('ngAirPair')
  .directive 'chat', ['$firebase', 'Session', ChatDirective]
