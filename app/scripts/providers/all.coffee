# if document.location.hostname != "localhost"
if true
  AddJS = require("./addjs/index") # custom analytics tracking

  if !addjs?
    window.addjs = new AddJS providers: { ga: { logging: off }, mp: { logging: off } }

  require("./cegg")()
  require("./adroll")()
  require("./blog")()
  require("./mixpanel")()
  require("./ga")()
  require("./gr")()
  require("./adroll")()
  require("./uservoice")() if window.useUserVoice
  require("./olark")() if window.useOlark
