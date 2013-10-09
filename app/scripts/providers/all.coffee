# if document.location.hostname != "localhost"
if true
  AddJS = require("./addjs/index") # custom analytics tracking

  if !addjs? 
    window.addjs = new AddJS providers: { ga: { logging: off }, mp: { logging: on } }

  require("./uservoice")()
  require("./ga")()
  require("./mixpanel")()