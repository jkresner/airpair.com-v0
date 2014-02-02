

mpInitCallback = function() {
  if (addjs && addjs.providers.mp)
  {
    addjs.providers.mp.trackSession()

    jQuery('.trackLogin,.trackCustomerLogin').click(function (e) {
      elmId = jQuery(this).parent().attr('id')
      addjs.trackClick(e,'/auth/google?return_to=/find-an-expert',addjs.events.customerLogin,elmId);
    });
    jQuery('.trackExpertLogin').click(function (e) {
      elmId = jQuery(this).parent().attr('id')
      addjs.trackClick(e,'/auth/google?return_to=/be-an-expert',addjs.events.expertLogin,elmId);
    });
  }
}


module.exports = function()
{
	var mixpanelId = "076cac7a822e2ca5422c38f8ab327d62";

	if (document.location.hostname == "localhost")
	{
		mixpanelId = "836dbdc21253fa8f3a68657c2f5ec4f1";
	}

  if (document.location.hostname != "localhost")
  {
    (function(e,b){if(!b.__SV){var a,f,i,g;window.mixpanel=b;a=e.createElement("script");a.type="text/javascript";a.async=!0;a.src=("https:"===e.location.protocol?"https:":"http:")+'//cdn.mxpnl.com/libs/mixpanel-2.2.min.js';f=e.getElementsByTagName("script")[0];f.parentNode.insertBefore(a,f);b._i=[];b.init=function(a,e,d){function f(b,h){var a=h.split(".");2==a.length&&(b=b[a[0]],h=a[1]);b[h]=function(){b.push([h].concat(Array.prototype.slice.call(arguments,0)))}}var c=b;"undefined"!==
typeof d?c=b[d]=[]:d="mixpanel";c.people=c.people||[];c.toString=function(b){var a="mixpanel";"mixpanel"!==d&&(a+="."+d);b||(a+=" (stub)");return a};c.people.toString=function(){return c.toString(1)+".people (stub)"};i="disable track track_pageview track_links track_forms register register_once alias unregister identify name_tag set_config people.set people.set_once people.increment people.append people.track_charge people.clear_charges people.delete_user".split(" ");for(g=0;g<i.length;g++)f(c,i[g]);
b._i.push([a,e,d])};b.__SV=1.2}})(document,window.mixpanel||[]);
mixpanel.init(mixpanelId, {'loaded':mpInitCallback});
  }
}
