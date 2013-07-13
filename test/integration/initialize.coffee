tests = [
  './beexpert/connect_test'
  './beexpert/infoform_test'
  './inbound/requestform_test'
  './request/customersignin_test'
  './request/infoform_test'
  './request/requestform_test'
  './request/requestmodel_test'
  './review/anonymous_test'
  './review/customer_test'
  './review/expert_test'
  './stories/emillee_test'
]

for test in tests
  require test
