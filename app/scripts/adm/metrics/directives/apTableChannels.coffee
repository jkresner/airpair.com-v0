

# DIRECTIVES
#----------------------------------------------


angular.module('AirpairAdmin').directive('apTableChannels', [() ->
  restrict: "EA"
  scope:
    report: "="
    reportTotals: "="
    interval: "@"
    hideSummary: "="
  templateUrl: "/adm/templates/orders_table_growth.html"
])

