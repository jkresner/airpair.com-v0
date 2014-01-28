http = require 'superagent'

module.exports = (url, callback) ->

    http.get(url)
      .set('host','docs.google.com')
      .set('user-agent','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.77 Safari/537.36')
      .set('x-chrome-variations','CPq1yQEIkrbJAQiltskBCKm2yQEIwbbJAQiiiMoBCLmIygE=')
      .end (e, cres) =>
        callback cres.text.replace /\/static/g, 'https://docs.google.com/static'
