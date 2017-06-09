ruleset fanCollection {
  meta {

    name "fan_collection"
    author "PicoLabs"
    //description "fan_collection"

    use module Subscriptions
    use module io.picolabs.wrangler.common alias common
    logging on
    
    shares fanStates ,__testing 
    provides fanStates ,__testing
  }

  global {


 __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ { "domain": "fan", "type": "airflow",
                                "attrs": [ 
                                  "level"        
                                 ] } ] }

    fanStates = function (){
      // wrapper for fanA and fanB state calls
      // returns an jason object with fan states keyed to there names
      ecis = collectionEcis();
      fan_a = common:skyQuery(ecis[0],"fanController","fan_state",{});
      fan_b = common:skyQuery(ecis[1],"fanController","fan_state",{});
      return1 = fan_a{"pin"};
      return2 = fan_b{"pin"};
      {
        "fan_a" : return1,
        "fan_b" : return2
      }

    };
    //private
    collectionEcis = function () { 
      return = Subscriptions:subscriptions(["attributes","subscriber_role"],"fan_controller").klog("subscriptions:   "); 
      raw_subs = return;//{"subscriptions"}; // array of subs
      ecis = raw_subs.map(function( subs ){
        r = subs.values().klog("subs.values(): ");
        v = r[0].klog("subscription we want");
        v.attributes.outbound_eci
        });
      ecis.klog("ecis: ")
    };
  }


  rule fanAOn {
    select when fan airflow level re#1#  
             or fan airflow level re#2# 
    pre {
      ecis = collectionEcis().klog("ecis for fanA");
    }
    event:send({"eid" : random:integer(100,2000) , "domain": "fan", "type": "new_status", "eci": ecis[0], "attrs": {"state" : "on"} })  
  }

  rule fanBOn {
    select when fan airflow level re#2#  // turn on fan B
    pre {
      ecis = collectionEcis();

    }   
    event:send({"eci": ecis[1], "attrs": {"state" : "on"}, "eid" : random:integer(100,2000) , "domain": "fan", "type": "new_status"})  
  }

  rule fanAOff {
    select when fan airflow level re#5#  
    pre {
      ecis = collectionEcis();
    }
    event:send({"eci": ecis[0], "attrs": {"state" : "off"}, "eid" : random:integer(100,2000) , "domain": "fan", "type": "new_status"})
  }

  rule fanBOff {
    select when fan airflow level re#5#
            or fan airflow level re#1#
    pre {
      ecis = collectionEcis();
    }
    event:send({"eci": ecis[1], "attrs": {"state" : "off"}, "eid" : random:integer(100,2000) , "domain": "fan", "type": "new_status"})
  }

}