module.exports = function()
{
  if (document.location.hostname != "localhost")
  {
    window.adroll_adv_id = "XF634YIRAZHM5AG2HSQDII";
    window.adroll_pix_id = "RJLKZHU5IFD2NP5M3C6X35";

    __adroll_loaded=true;
    var scr = document.createElement("script");
    var host = (("https:" == document.location.protocol) ? "https://s.adroll.com" : "http://a.adroll.com");
    scr.setAttribute('async', 'true');
    scr.type = "text/javascript";
    scr.src = host + "/j/roundtrip.js";
    ((document.getElementsByTagName('head') || [null])[0] ||
      document.getElementsByTagName('script')[0].parentNode).appendChild(scr);
  }
}
