# if document.location.hostname != "localhost"
if true
  require("./cegg")()
  require("./segmentio")()
  require("./adroll")()
  require("./olark")()

  AddJS = require("./addjs/index") # custom analytics tracking

  if !addjs?
    window.addjs = new AddJS

