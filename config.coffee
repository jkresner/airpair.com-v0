exports.config =

  # do not build test directory in debug or release (only test)
  paths:        watched: ['app','vendor']

  server:
    env:  'dev'
    path: 'app.coffee'
    port: 3333
    base: '/'
    run: yes

  overrides:
    test:
      paths:    watched: ['app','vendor', 'test']
      plugins:  autoReload: enabled: false
      server:   { port: 4444, env: 'test' }
    prod:
      optimize: true
      sourceMaps: false


  files:
    javascripts:
      joinTo:
       'javascripts/app.js': /^app/
       'javascripts/vendor.js': /^vendor/
       'javascripts/providers.js': /^app\/scripts\/providers/
       'test/javascripts/test.js': /^test(\/|\\)(?=integration)/
       'test/javascripts/test-data.js': /^test(\/|\\)(?=data)/
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
          'vendor/scripts/picker.js'
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

  coffeelint:
    pattern: /^app\/.*\.coffee$/
    options:
      indentation:
        value: 2
        level: "error"

global.brunch = exports.config.server
