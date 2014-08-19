angular.module('segmentio', ['ng'])
    .factory('segmentio', ['$rootScope', '$window', '$location', '$log',
        function($rootScope, $window, $location, $log) {

            // ADD ON FOR AUTO UTM PARSING
            getReferrerTraits = function() {
              // Requires: jQuery, jQuery.cookie, segment.io

              var analytics_args = [],
                  analytics_traits = {},
                  firstReferrer,
                  firstCampaign,
                  latestReferrer,
                  latestCampaign,
                  utmSource,
                  utmMedium,
                  utmContent,
                  utmTerm;

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

              // Get the first and latest campaigns and referrers
              latestReferrer = referralHost;
              latestCampaign = (QueryString.utm_campaign || null);
              utmSource = (QueryString.utm_source || null);
              utmMedium = (QueryString.utm_medium || null);
              utmContent = (QueryString.utm_content || null);
              utmTerm = (QueryString.utm_term || null);

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
              if(firstCampaign !== null && firstCampaign != 'null') {
                analytics_traits['utm_campaign_first'] = firstCampaign;
              }
              if(latestReferrer !== null && latestReferrer.length > 0) {
                analytics_traits['Latest Referrer'] = latestReferrer;
              }
              if(latestCampaign !== null) {
                analytics_traits['utm_campaign'] = latestCampaign;
                analytics_traits['utm_source'] = utmSource;
                analytics_traits['utm_medium'] = utmMedium;
                analytics_traits['utm_content'] = utmContent;
                analytics_traits['utm_term'] = utmTerm;
              }

              return analytics_traits;
            }


            var service = {};

            $window.analytics = $window.analytics || [];

            // Define a factory that generates wrapper methods to push arrays of
            // arguments onto our `analytics` queue, where the first element of the arrays
            // is always the name of the analytics.js method itself (eg. `track`).
            var methodFactory = function(type) {
                return function() {
                    var args = Array.prototype.slice.call(arguments, 0);
                    $log.debug('Call segmentio API with', type, args);
                    if ($window.analytics.initialized) {
                        $log.debug('Segmentio API initialized, calling API');
                        $window.analytics[type].apply($window.analytics, args);
                    } else {
                        $log.debug('Segmentio API not yet initialized, queueing call');
                        $window.analytics.push([type].concat(args));
                    }
                };
            };

            // Loop through analytics.js' methods and generate a wrapper method for each.
            var methods = ['identify', 'track', 'trackLink', 'trackForm', 'trackClick',
                'trackSubmit', 'page', 'pageview', 'ab', 'alias', 'ready', 'group'
            ];
            for (var i = 0; i < methods.length; i++) {
                service[methods[i]] = methodFactory(methods[i]);
            }

            // Listening to $viewContentLoaded event to track pageview
            $rootScope.$on('$viewContentLoaded', function() {
                if (service.location != $location.path()) {
                    service.location = $location.path();
                    service.pageview(service.location);
                }
            });

            /**
             * @description
             * Load Segment.io analytics script
             * @param apiKey The key API to use
             */
            service.load = function(apiKey) {
                // Create an async script element for analytics.js.
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.async = true;
                script.src = ('https:' === document.location.protocol ? 'https://' : 'http://') +
                    'd2dq2ahtl5zl1z.cloudfront.net/analytics.js/v1/' + apiKey + '/analytics.js';

                // Find the first script element on the page and insert our script next to it.
                var firstScript = document.getElementsByTagName('script')[0];
                firstScript.parentNode.insertBefore(script, firstScript);
            };

            // After including segment, but before using it anywhere...

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

            return service;
        }
    ]);
