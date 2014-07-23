module.exports = (app) ->
  app.controller 'AutoMatchController',
    ($scope, $http, $window, Session, Restangular) ->
      _.extend $scope,
        name: "automatchController"
        budget: 100
        pricingOptions: ['opensource', 'private', 'nda', 'subscription', 'offline']
        pricing: 'private'
        tagsAvailable: []
        tagsSelected: []
        sort: '-score'

      Restangular.all('tags').getList().then (tags) ->
        $scope.tagsAvailable = _.pluck(tags, 'soId')

      $scope.$watchCollection 'tagsSelected', (newTags, oldTags) ->
        return if newTags == oldTags
        Restangular.all("match/tags/" + newTags)
          .getList
            budget: $scope.budget
            pricing: $scope.pricing
          .then (experts) ->
            console.log experts
            $scope.experts = experts
