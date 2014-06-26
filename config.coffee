exports.config =

  # do not build test directory in debug or release (only test)
  paths:        watched: ['app','vendor','lib','mail']

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
      paths:    watched: ['app','vendor', 'test','lib','mail']
      plugins:  autoReload: enabled: false
      server:   { port: 4444, env: 'test' }
    prod:
      optimize: true


  files:
    javascripts:
      joinTo:
       'javascripts/vendor.js': /^vendor/
       'javascripts/ap.js': /(scripts\/ap|scripts\/shared|scripts\/providers|lib\/mix)/
       'javascripts/adm.js': /(scripts\/adm|scripts\/shared|scripts\/providers|lib\/mix)/
       'javascripts/adm-ang.js': /(scripts\/angular|lodash|moment-2.6|scripts\/adm-ang|lib\/mix)/
       'javascripts/providers.js': /^app\/scripts\/providers/
       'javascripts/home.js': /providers\/(home|addjs|ga|mix|mixpanel|cegg|olark|adroll)|bootstrap3\/dropdown|bootstrap3\/collapse/
       'test/javascripts/test.js': /^test(\/|\\)(?=integration)/
       'test/javascripts/test-data.js': /^test(\/|\\)(?=data)/
       'test/javascripts/test-vendor.js': /^test(\/|\\)(?=vendor)/
      order:
        # Files in `vendor` directories are compiled before other files
        # even if they aren't specified in order.
        before: [
          'vendor/scripts/angular.js'
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
      defaultExtension: 'scss'
      joinTo:
        'css/ap.css': /(css\/ap\/)/
        'css/adm.css': /(css\/adm\/|css\/shared)/
        'css/ap-old.css': /(css\/ap-old)/
        'css/adm-old.css': /(css\/adm-old|vendor\/css\/shared)/
        'test/stylesheets/test.css': /^test/
      order:
        before: [
          'vendor/css/adm-bb/normalize.css'
          'vendor/css/adm-bb/bootstrap.css'
          'vendor/css/adm-bb/bootstrap-responsive.css'
          'vendor/css/ap/epik.css'
          'vendor/css/shared/jquery.datepicker.css'
          'vendor/css/shared/jquery.timepicker.css'
          'vendor/css/shared/bootstrap-typeahead.css'
          'app/css/shared/alert.scss'
          'app/css/shared/base.scss'
          'app/css/shared/form.scss'
          'app/css/shared/icon.scss'
          'app/css/shared/label.scss'
          'app/css/shared/table.scss'
          'app/css/shared/tag.scss'
          'app/css/adm/base.scss'

        ]
        after: []
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
