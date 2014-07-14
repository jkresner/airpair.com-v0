module.exports = function(segmentioKey) {
  // Create a queue, but don't obliterate an existing one!
  window.analytics = window.analytics || [];

  // A list of the methods in Analytics.js to stub.
  window.analytics.methods = ['identify', 'group', 'track',
    'page', 'pageview', 'alias', 'ready', 'on', 'once', 'off',
    'trackLink', 'trackForm', 'trackClick', 'trackSubmit'];

  // Define a factory to create stubs. These are placeholders
  // for methods in Analytics.js so that you never have to wait
  // for it to load to actually record data. The `method` is
  // stored as the first argument, so we can replay the data.
  window.analytics.factory = function(method){
    return function(){
      var args = Array.prototype.slice.call(arguments);
      args.unshift(method);
      window.analytics.push(args);
      return window.analytics;
    };
  };

  // For each of our methods, generate a queueing stub.
  for (var i = 0; i < window.analytics.methods.length; i++) {
    var key = window.analytics.methods[i];
    window.analytics[key] = window.analytics.factory(key);
  }

  // Define a method to load Analytics.js from our CDN,
  // and that will be sure to only ever load it once.
  window.analytics.load = function(key){
    if (document.getElementById('analytics-js')) return;

    // Create an async script element based on your key.
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.id = 'analytics-js';
    script.async = true;
    script.src = ('https:' === document.location.protocol
        ? 'https://' : 'http://')
      + 'cdn.segment.io/analytics.js/v1/'
      + key + '/analytics.min.js';

    // Insert our script next to the first script element.
    var first = document.getElementsByTagName('script')[0];
    first.parentNode.insertBefore(script, first);
  };

  // Add a version to keep track of what's in the wild.
  window.analytics.SNIPPET_VERSION = '2.0.9';

  // Load Analytics.js with your key, which will automatically
  // load the tools you've enabled for your account. Boosh!
  window.analytics.load(segmentioKey);

  // Make the first page call to load the integrations. If
  // you'd like to manually name or tag the page, edit or
  // move this call however you'd like.
  /*
     window.analytics.page();
     */



  // ADD ON FOR AUTO UTM PARSING
  getReferrerTraits = function() {
    // Requires: jQuery, jQuery.cookie, segment.io

    // TODO: Update referralHost:blackList with your domain, so we only track external referrers. 

    var analytics_args = [],
        analytics_traits = {},
        acquisitionSource,
        firstReferrer,
        firstCampaign,
        latestReferrer,
        latestCampaign;


    // referralHost = the domain name of the referrer of this request, or null
    var referralHost = function() {
      var blackList = ['', null, 'yourdomain.com'];
      var host = document.referrer.toLowerCase().match(/\:\/\/[w\.]*([a-z\-0-9\.]+)\/?/i);

      // Break a match out of the array
      host !== null && (host = host[1]);

      // Invoke black list
      return (blackList.indexOf(host) > -1) ? null : host;
    } ();

    // Parameter Grabber via http://stackoverflow.com/a/979995/311901 
    var QueryString = function () {
      var query_string = {};
      var query = window.location.search.substring(1);
      var vars = query.split("&");
      for (var i=0;i<vars.length;i++) {
        var pair = vars[i].split("=");
        // If first entry with this name
        if (typeof query_string[pair[0]] === "undefined") {
          query_string[pair[0]] = pair[1];
          // If second entry with this name
        } else if (typeof query_string[pair[0]] === "string") {
          var arr = [ query_string[pair[0]], pair[1] ];
          query_string[pair[0]] = arr;
          // If third or later entry with this name
        } else {
          query_string[pair[0]].push(pair[1]);
        }
      } 
      return query_string;
    } ();

    // log this users' acquisition source:
    //  - utm_source overrides referrer
    //  - Referrer only set when present and not blacklisted
    //  - Directs are not logged. This means the last used referrer will remain. 
    acquisitionSource = (QueryString.utm_source || referralHost);
    if(acquisitionSource !== null) {
      analytics_traits['acquisitionSource'] = acquisitionSource;
    }

    // Get the first and latest campaigns and referrers
    latestReferrer = referralHost;
    latestCampaign = (QueryString.utm_campaign || null);
    firstReferrer  = $.cookie('first_referrer');
    firstCampaign  = $.cookie('first_campaign');

    // Persist the first referer and campaign
    if(firstReferrer == null) {
      firstReferrer = latestReferrer;
      $.cookie('first_referrer', firstReferrer);
    }
    if(firstCampaign == null) {
      firstCampaign = latestCampaign;
      $.cookie('first_campaign', firstCampaign);
    }

    // Append first and latest referrers to the traits being reported with each event
    analytics_traits['firstReferrer'] = firstReferrer;
    analytics_traits['firstCampaign'] = firstCampaign;
    analytics_traits['latestReferrer'] = latestReferrer;
    analytics_traits['latestCampaign'] = latestCampaign;

    return analytics_traits;
  }

  // After including analytics.js, but before using it anywhere...

  // Wrap identify so that all traits persist in a cookie, 
  // and each call is merged with previously persisted traits
  var identifyFn = analytics['identify'];
  analytics['identify'] = function(){
    var new_traits,
        new_arguments = [],
        referrer_traits,
        id,
        old_traits = {},
        all_traits = {};

    // First arg might be the ID, or the attributes may be set anonymously
    if(arguments[0] && (typeof arguments[0] == 'string')){
      arguments = $.map(arguments, function(value, index) { return value; })
      id = arguments.shift();
    }
    new_traits = arguments[0];

    // Collect existing and previous traits together
    if(typeof $.cookie('analytics_user_traits') !== 'undefined') {
      old_traits = _.extend({}, JSON.parse($.cookie('analytics_user_traits')));
    }
    all_traits = _.extend({}, old_traits, new_traits);

    // Also collect and merge referrers and campaigns
    referrer_traits = getReferrerTraits();
    all_traits = _.extend({}, all_traits, referrer_traits);

    // Persist traits for next time
    $.cookie("analytics_user_traits", JSON.stringify(all_traits));

    // identify the user with all traits to the analytics services
    if(typeof id == 'string') { new_arguments.push(id); }
    new_arguments.push(all_traits);
    identifyFn.apply(identifyFn, new_arguments);
  };
}
