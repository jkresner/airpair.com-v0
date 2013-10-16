module.exports = (grep) ->

  window.hlpr = require './ui-helper'
  window.data = require '/test/data/all'

  # variables declared in globals are ignored:
  # https://github.com/cjohansen/Sinon.JS/issues/143
  globalIgnores = [
    'script*',
    #'__screenCapturePageContext__',
    #'setTimeout',
    #'setInterval',
    #'clearTimeout',
    #'clearInterval',
    'initApp',
    'router',
    #'__e3_',
    #'_xdc_',
    'jQuery*',
    'PAYPAL'
  ]

  mocha.setup
    ui:'bdd'
    grep: grep
    globals: globalIgnores
    timeout: 5000

  window.expect = chai.expect;

  # require.list().filter((_) -> /test$/.test _).map(require)

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
    './review/book_test'
    './tags/tagsadmin_test'
    './stories/emillee_test'
  ]

  require test for test in tests

  if window.mochaPhantomJS
    mochaPhantomJS.run()
  else
    mocha.run()