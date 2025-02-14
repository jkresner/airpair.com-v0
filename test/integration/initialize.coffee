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

  mocha.setup({timeout: 5000, ui:'bdd', grep: grep, globals: globalIgnores})

  window.expect = chai.expect;

  # require.list().filter((_) -> /test$/.test _).map(require)

  tests = [
    './beexpert/connect_test'
    './beexpert/infoform_test'
    './pipeline/requestform_test'
    './request/infoform_test'
    './request/requestform_test'
    './request/requestmodel_test'
    './review/anonymous_test'
    './review/customer_test'
    './review/expert_test'
    './review/book_test'
    # './review/bookStripe_test'
    # './settings/paypal_test'
    # './tags/tagsadmin_test'
    './stories/emillee_test'
    './stories/ramon_test'
    './stories/bchristie_test'
    './stories/jdowd_test'
  ]

  require test for test in tests

  if window.mochaPhantomJS
    mochaPhantomJS.run()
  else
    mocha.run()
