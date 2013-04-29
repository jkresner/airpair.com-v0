# See docs at http://brunch.readthedocs.org/en/latest/config.html.

exports.config =

  env:
    mode: 'dev'

  db: 'airpair_dev'

  server:
    path: 'app.coffee'
    port: 3333
    base: '/'
    run: yes

  coffeelint:
    pattern: /^app\/.*\.coffee$/
    options:
      indentation:
        value: 2
        level: "error"

  files:

    javascripts:
      joinTo:
       'javascripts/app.js': /^app/
       'javascripts/vendor.js': /^vendor/
       'test/javascripts/test.js': /^test(\/|\\)(?!vendor)/
       'test/javascripts/test-vendor.js': /^test(\/|\\)(?=vendor)/
      order:
        # Files in `vendor` directories are compiled before other files
        # even if they aren't specified in order.
        before: [
          'vendor/scripts/console-helper.js'
          'vendor/scripts/jquery.js'
          'vendor/scripts/lodash.js'
          'vendor/scripts/backbone.js'
          'vendor/scripts/backbone.validation.js'
          'vendor/scripts/backbone.validation_bootstrap.js'
        ]

    stylesheets:
      joinTo:
        'stylesheets/app.css': /^(app|vendor)/
        'test/stylesheets/test.css': /^test/
      order:
        before: [
          'vendor/styles/normalize.css',
          'vendor/styles/bootstrap.css'
        ]
        after: ['vendor/styles/helpers.css']

    templates:
      joinTo: 'javascripts/app.js'

global.cfg = exports.config