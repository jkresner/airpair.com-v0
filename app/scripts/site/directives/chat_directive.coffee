ChatDirective = ($firebase, session) ->
  templateUrl: '/templates/shared/chat_template'

  scope:
    title: '@' # string attr value passed in
    slug: '@'  # optional, default is to grab from ngModel.slug
    ngModel: '='  # bind by reference passed in

  restrict: 'E'

  ## ngModel should have a slug attribute
  link: (scope, element, attributes) ->
    # use slug to key the chat stream
    firebaseSlug = scope.slug or scope.ngModel?.slug

    # guard against misconfiguration
    return if not firebaseSlug

    # get a firebase reference
    firebaseSlug = firebaseSlug.replace(".", "")
    ref = new Firebase("https://airpair-chat.firebaseio.com/chat/#{firebaseSlug}")

    if not session.isSignedIn()
      # read-only mode
      $(element).find('#chat_entry').remove()
    else
      scope.user = session.data.user.google._json

      console.log session.data.user

      # authenticate firebase session
      ref.auth session.data.user.fba, (error) ->
        if error
          console.log("Firebase login failed!", error)
        else
          debugger


      scope.addMessage = ->
        scope.messages.$add
          from: scope.user.name
          pic: scope.user.picture
          content: scope.message
          sent_at: Firebase.ServerValue.TIMESTAMP

        # reset input
        scope.message = ""

    # track latest messages in this chat room
    scope.messages = $firebase(ref.limit(250)).$asArray()

angular
  .module('ngAirPair')
  .directive 'chat', ['$firebase', 'Session', ChatDirective]
