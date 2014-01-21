//  http://stackoverflow.com/questions/8059914/express-js-hbs-module-register-partials-from-hbs-file

module.exports = { register: function() {

  var hbs = require('hbs');
  var fs = require('fs');

  var partialsDir = __dirname + '/public/partials';

  var filenames = fs.readdirSync(partialsDir);

  filenames.forEach(function (filename) {
    var matches = /^([^.]+).hbs$/.exec(filename);
    if (!matches) {
      return;
    }
    var name = matches[1];
    var template = fs.readFileSync(partialsDir + '/' + filename, 'utf8');
    hbs.registerPartial(name, template);
  });
} }
