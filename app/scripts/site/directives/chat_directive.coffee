ChatDirective = ($firebase, session) ->
  templateUrl: '/templates/shared/chat_template'

  scope:
    title: '@'  # string attr value passed in
    slug: '@'  # optional, default is to grab from ngModel.slug
    ngModel: '='  # bind by reference passed in

  restrict: 'E'

  ## ngModel should have a slug attribute
  link: (scope, element, attributes) ->
    if not session.isSignedIn()
      $(element).find('#chat_entry').remove()
    else
      scope.user = session.data.user.google._json
      scope.addMessage = ->
        msg =
          from: scope.user.name
          pic: scope.user.picture
          content: scope.message
          sent_at: Firebase.ServerValue.TIMESTAMP

        console.log msg
        scope.messages.$add msg

        scope.message = ""

    # use slug to key the chat stream
    firebaseSlug = scope.slug or scope.ngModel.slug

    # guard against misconfiguration
    return if not firebaseSlug

    firebaseSlug = firebaseSlug.replace(".", "")
    ref = new Firebase("https://airpair-chat.firebaseio.com/chat/#{firebaseSlug}")
    scope.messages = $firebase(ref.limit(200)).$asArray()

angular
  .module('ngAirPair')
  .directive 'chat', ['$firebase', 'Session', ChatDirective]
