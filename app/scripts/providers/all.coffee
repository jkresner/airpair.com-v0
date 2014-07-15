# if document.location.hostname != "localhost"
if true
  require("./cegg")()
  require("./blog")()
  require("./uservoice")() if window.useUserVoice
  require("./olark")() if window.useOlark
