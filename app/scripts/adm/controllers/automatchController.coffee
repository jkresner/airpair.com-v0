module.exports = (app) ->
  app.controller 'AutoMatchController',
    ($scope, $http, $window, Session, Restangular) ->
      _.extend $scope,
        name: "automatchController"
        budget: 100
        popularTags: ["android","aws","azure","c","c++","c#","chef","coffeescript","css","email","html5","ios","java","javascript","jquery",".net","linux","mongodb","mysql","node.js","objective-c","php","postgres","python","redis","ruby-on-rails","ruby","wordpress"]
        pricingOptions: ['opensource', 'private', 'nda', 'subscription', 'offline']
        pricing: 'private'
        tagsAvailable: []
        tagsSelected: []
        sort: '-score'

        selectTag: (tag) ->
          $scope.tagsSelected.push(tag) unless _.contains($scope.tagsSelected, tag)

        tagColor: (tag) ->
          if tag?
            # default appearance
            styleAttrs =
              border: '1px solid silver'
              cursor: 'pointer'
              'text-shadow' : '0 0 4px black'

            # background color based on a hex representation of the tag name
            rootHex = _.map(tag, (c) ->c.charCodeAt(0).toString(15))
            color = "#" + _.first(rootHex, 3).join("").split("").reverse().join("")
            styleAttrs['background-color'] = color

            # highlight chosen tags
            styleAttrs['border'] = '3px solid #CE5424' if _.contains($scope.tagsSelected, tag)

            return styleAttrs

        update: ->
          Restangular.all("match/tags/" + $scope.tagsSelected)
            .getList
              budget: $scope.budget
              pricing: $scope.pricing
            .then (experts) ->
              $scope.experts = experts

      # populate available tags from the server
      Restangular.all('tags').getList().then (tags) ->
        $scope.tagsAvailable = _.pluck(tags, 'soId')

      # monitor tags selected by user and update list of experts
      $scope.$watchCollection 'tagsSelected', (newTags, oldTags) ->
        return if newTags == oldTags
        $scope.update()
