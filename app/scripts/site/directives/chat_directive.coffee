ChatDirective = ($firebase, session) ->
  templateUrl: '/templates/shared/chat_template'

  scope:
    title: '@' # string attr value passed in
    slug: '@'  # optional, default is to grab from ngModel.slug
    questions: '@' # boolean flag to turn on questions
    ngModel: '='  # bind by reference passed in

  restrict: 'E'

  ## ngModel should have a slug attribute
  link: (scope, element, attributes) ->
    # use slug to key the chat stream
    firebaseSlug = scope.slug or scope.ngModel?.slug

    # guard against misconfiguration
    return if not firebaseSlug

    # get a firebase reference
    firebaseSlug = firebaseSlug.replace(".", "") # better replace logic
    ref = new Firebase(session.data.firebase.path + firebaseSlug)

    if not session.isSignedIn()
      # read-only mode
      $(element).find('#chat_entry').remove()
    else
      scope.user = session.data.user.google._json
      scope.isAdmin = session.data.firebase.isAdmin

      # authenticate firebase session
      ref.auth session.data.firebase.token, (error) ->
        if error
          console.log("Firebase login failed! Chat is read-only.", error)

      # ⇊ ⇊ ⇊ authorization functions  ⇊ ⇊ ⇊

      scope.canDelete = (message) ->
        @isAdmin or (message.user_id == @user.id)

      scope.canFlag = (message) ->
        message.user_id != @user.id

      scope.canMarkAsQuestion = (message) ->
        @questions and @canDelete(message) and not @isQuestion(message) and not message.unmarked_as_question

      scope.canVoteUp = (message) ->
        @isQuestion(message) and not @isVoter(message)

      # ⇊ ⇊ ⇊ click handlers ⇊ ⇊ ⇊

      scope.delete = (message) ->
        @messages.$remove message
        false

      scope.markAsQuestion = (message) ->
        message.voters = [_.pick(@user, 'id', 'name', 'link', 'picture')]
        @messages.$save(message)
        false

      scope.voteForQuestion = (message) ->
        message.voters.$add _.pick(@user, 'id', 'name', 'link', 'picture')
        @messages.$save(message)
        false

      scope.addMessage = ->
        msg =
          from: @user.name
          pic: @user.picture
          content: @message
          user_id: @user.id
          sent_at: Firebase.ServerValue.TIMESTAMP
          voters: []

        scope.messages.$add msg

        # reset input
        scope.message = ""

      scope.isVoter = (message) ->
        _.find(message.voters, (v) -> v.id == scope.user.id)

    # ⇈ ⇈ ⇈ end of if not session.isSignedIn() ⇈ ⇈ ⇈

    scope.isQuestion = (message) ->
      (message.voters? and message.voters.length > 0)

    scope.hidePic = (index) ->
      @messages[index].user_id == @messages[index - 1]?.user_id

    scope.voteCount = (message) ->
      return unless @isQuestion(message)
      votes = message.voters.length
      if votes == 1
        return votes + " vote"
      else
        return votes + " votes"

    # finally, track latest messages in this chat room
    scope.messages = $firebase(ref.limit(250)).$asArray()

angular
  .module('ngAirPair')
  .directive 'chat', ['$firebase', 'Session', ChatDirective]
