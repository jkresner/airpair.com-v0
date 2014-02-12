# http://stackoverflow.com/questions/8059914/express-js-hbs-module-register-partials-from-hbs-file
hbs = require('hbs')
fs  = require('fs')

module.exports =
  register: (rootDir, subDirs) ->

    for dir in subDirs
      partialsDir = rootDir + dir
      filenames = fs.readdirSync(partialsDir)

      for filename in filenames
        matches = /^([^.]+).hbs$/.exec(filename)
        if matches
          name = matches[1]
          template = fs.readFileSync(partialsDir + '/' + filename, 'utf8')
          hbs.registerPartial(name, template)
