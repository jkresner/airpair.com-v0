SessionFactory = ($http, $window, segmentio) ->
  segmentio.load($window.session.segmentioKey)
  session =
    data: $window.session

    isSignedIn: ->
      @data? && @data.user? && @data.user._id?

    id: ->
      if @isSignedIn()
        @data.user._id

    name: ->
      if @isSignedIn()
        @data.user.google.displayName

    imageUrl: ->
      if @isSignedIn()
        @data.user.google._json.picture
      else
        "/images/avatars/default.jpg"

    updateSession: ->
      $http.get('/api/session')
        .success (data) =>
          @data = data
        .error (data) ->
          console.log('Error: ' + data)

    googleData: ->
      if @isSignedIn()
        @data.user.google._json

    alias: ->
      if @googleData? && @googleData.email?
        segmentio.alias(@googleData.email, null, null, @identify)
      else
        console.log("Aliasing new user Failed")

    identify: (additionalProperties={}) =>
      if @googleData? && @googleData.email?
        properties =
          avatar: @googleData.picture
          email: @googleData.email
          name: @googleData.name
          lastName: @googleData.family_name
          firstName: @googleData.given_name
          createdAt: @googleData.created_at
        properties[key] = val for key, val of additionalProperties
        segmentio.identify @googleData.email, properties
      else
        segmentio.identify(additionalProperties)

    trackEvent: (action, props) ->
      segmentio.track action, props

    trackPageView: (name, data) ->
      # segment.io automatically tracks page views
      # only use this method for client side page
      # views (a la angular)
      segmentio.page(name, data)

    trackLink: (link, name, options) ->
      segmentio.trackLink(link, name, options)

  session

angular
  .module('ngAirPair')
  .factory('Session', ['$http', '$window', 'segmentio', SessionFactory])
