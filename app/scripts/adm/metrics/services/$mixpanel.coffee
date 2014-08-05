

# Mixpanel Service - To talk to mixpanel data api
#-------------------------------------------------

angular.module('AirpairAdmin').factory('$mixpanel', () ->
    
  $mixpanel = new MixpanelExport
    api_key: "700fdc0126f37c4a5b22666f92be6be3"
    api_secret: "468ef07fb0edeb07c1c47be0269e3f6f"

      
)

