exports.config =

  # do not build test directory in debug or release (only test)
  paths:        watched: ['app','vendor','lib','mail']

  server:
    env:  'dev'
    path: 'app.coffee'
    port: 3333
    base: '/'
    run: yes

  overrides:
    test:
      paths:    watched: ['app','vendor', 'test','lib','mail']
      plugins:  autoReload: enabled: false
      server:   { port: 4444, env: 'test' }
    prod:
      optimize: true
      sourceMaps: false


  files:
    javascripts:
      joinTo:
       'javascripts/vendor.js': /^vendor/
       'javascripts/ap.js': /(scripts\/ap|scripts\/shared|scripts\/providers|lib\/mix)/
       'javascripts/adm.js': /(scripts\/adm|scripts\/shared|scripts\/providers|lib\/mix)/
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
          'vendor/scripts/backbone.badass.js',
          'vendor/scripts/picker.js',
          'vendor/scripts/picker.date.js',
          'vendor/scripts/jquery.timepicker.js'
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
      joinTo:
       'javascripts/adm.js': /(^mail|scripts\/adm|scripts\/shared)/
       'javascripts/ap.js': /(scripts\/ap|scripts\/shared)/

  coffeelint:
    pattern: /^app\/.*\.coffee$/
    options:
      indentation:
        value: 2
        level: "error"

global.brunch = exports.config.server
