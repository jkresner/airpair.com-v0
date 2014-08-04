

# DIRECTIVES
#----------------------------------------------


angular.module('AirpairAdmin').directive('apTableGrowth', [() ->
  restrict: "EA"
  scope:
    report: "="
    reportTotals: "="
    interval: "@"
    hideSummary: "="
  templateUrl: "/adm/templates/orders_table_growth.html"
])

