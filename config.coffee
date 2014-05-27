exports.config =

  # do not build test directory in debug or release (only test)
  paths:        watched: ['app','vendor']

  server:
    env:  'dev'
    path: 'app.coffee'
    port: 3333
    base: '/'
    run: yes

  plugins:
    sass:
      options:
        includePaths: ['app/assets/css']

  sourceMaps: false


  overrides:
    dev:
      sourceMaps: true
    test:
      paths:    watched: ['app','vendor', 'test']
      plugins:  autoReload: enabled: false
      server:   { port: 4444, env: 'test' }
    prod:
      optimize: true


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
        ]
    stylesheets:
      defaultExtension: 'scss'
      joinTo:
        'css/ap.css': /(css\/ap|css\/shared|css\/old)/
        'css/adm.css': /(css\/adm|css\/shared)/
        'test/stylesheets/test.css': /^test/
      order:
        before: [
          'vendor/css/adm/normalize.css',
          'vendor/css/adm/bootstrap.css',
          'vendor/css/adm/bootstrap-responsive.css',
          'vendor/css/ap/epik.css',
          'vendor/css/shared/jquery.datepicker.css',
          'vendor/css/shared/jquery.timepicker.css',
          'vendor/css/shared/bootstrap-typeahead.css',
          'app/css/shared/alert.scss',
          'app/css/shared/base.scss',
          'app/css/shared/form.scss',
          'app/css/shared/icon.scss',
          'app/css/shared/label.scss',
          'app/css/shared/table.scss',
          'app/css/shared/tag.scss',
          'app/css/adm/base.scss',
          'app/css/ap/base.scss',
          'app/css/ap/snippets.scss',

        ]
        after: []
    templates:
      joinTo: 'javascripts/app.js'

  coffeelint:
    pattern: /^app\/.*\.coffee$/
    options:
      indentation:
        value: 2
        level: "error"

global.brunch = exports.config.server
