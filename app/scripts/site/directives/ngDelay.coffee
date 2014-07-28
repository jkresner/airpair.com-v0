NgDelay = ($timeout) ->
  restrict: "A"
  scope: true
  compile: (element, attributes) ->
    expression = attributes["ngChange"]
    return unless expression
    ngModel = attributes["ngModel"]
    attributes["ngModel"] = "$parent." + ngModel  if ngModel
    attributes["ngChange"] = "$$delay.execute()"
    post: (scope, element, attributes) ->
      scope.$$delay =
        expression: expression
        delay: scope.$eval(attributes["ngDelay"])
        execute: ->
          state = scope.$$delay
          state.then = Date.now()
          $timeout (->
            scope.$parent.$eval expression  if Date.now() - state.then >= state.delay
          ), state.delay

angular
  .module('ngAirPair')
  .directive "ngDelay", ["$timeout", NgDelay]
