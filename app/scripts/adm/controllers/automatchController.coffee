AutoMatchController = ($scope, $location, Restangular) ->
  _.extend $scope,
    name: "automatchController"
    budget: $location.search().budget or 250
    pricing: $location.search().pricing or 'private'
    popularTags: ["android","aws","azure","c","c++","c#","chef","coffeescript","css","email","html5","ios","java","javascript","jquery",".net","linux","mongodb","mysql","node.js","objective-c","php","postgres","python","redis","ruby-on-rails","ruby","wordpress"]
    pricingOptions: ['opensource', 'private', 'nda', 'subscription', 'offline']
    tagsAvailable: []
    tagsSelected: _.compact($location.search().tags?.split(','))
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
        if _.contains($scope.tagsSelected, tag)
          styleAttrs['border'] = '3px solid #CE5424'
          styleAttrs['margin'] = '2px'
          styleAttrs['font-size'] = '120%'

        return styleAttrs

    update: ->
      params =
        tags: $scope.tagsSelected.join(",")
        budget: $scope.budget
        pricing: $scope.pricing

      $location.search params
      Restangular.all("match/tags")
        .getList(params)
        .then (experts) ->
          _.each experts, (e) ->
            e.tags.reverse()
          $scope.experts = experts


  # populate available tags from the server
  Restangular.all('tags').getList().then (tags) ->
    $scope.tagsAvailable = _.pluck(tags, 'soId')

  # monitor tags selected by user and update list of experts
  $scope.$watchCollection 'tagsSelected', (newTags, oldTags) ->
    $scope.update()


angular
  .module('ngAirPair')
  .controller('AutoMatchController', ['$scope', '$location', 'Restangular', AutoMatchController])
