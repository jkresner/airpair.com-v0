module.exports = (app) ->
  app.controller 'AutoMatchController',
    ($scope, $http, $window, Session, Restangular) ->
      _.extend $scope,
        name: "automatchController"
        options: []
        tags: []
        predicate: ''

      Restangular.all('tags').getList().then (tags) ->
        $scope.options = _.pluck(tags, 'soId')

      $scope.$watchCollection 'tags', (tags) ->
        Restangular.all("experts/automatch/tags/" + tags).getList().then (experts) ->
          $scope.experts = experts
