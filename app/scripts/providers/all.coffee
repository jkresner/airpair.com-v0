# if document.location.hostname != "localhost"
if true
  require("./cegg")()
  require("./adroll")()
  require("./blog")()
  require("./segmentio")()
  require("./gr")()
  require("./adroll")()
  require("./uservoice")() if window.useUserVoice
  require("./olark")() if window.useOlark

  AddJS = require("./addjs/index") # custom analytics tracking

  if !addjs?
    window.addjs = new AddJS providers: { ga: { logging: off }, mp: { logging: off } }

