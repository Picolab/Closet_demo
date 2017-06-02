ruleset fanCollection {
  meta {

    name "fan_collection"
    author "PicoLabs"
    //description "fan_collection"

    use module wrangler
    
    logging on
    
    shares fanStates
    provides fanStates
  }

  global {
    fanStates = function (){
      // wrapper for fanA and fanB state calls
      // returns an jason object with fan states keyed to there names
      ecis = collectionEcis();
      fan_a = wrangler:skyQuery(ecis[0],"b507888x0.dev","fan_state",{});
      fan_b = wrangler:skyQuery(ecis[1],"b507888x0.dev","fan_state",{});
      return1 = fan_a{"pin"};
      return2 = fan_b{"pin"};
      {
        "fan_a" : return1,
        "fan_b" : return2
      }

    };
    //private
    collectionEcis = function () {
        return = wrangler:subscriptions(unknown,"subscriber_role","fan_controller"); 
        raw_subs = return{"subscriptions"}; // array of subs
        ecis = raw_subs.map(function( subs ){
          r = subs.values().klog("subs.values(): ");
          v = r[0];
          v{"outbound_eci"}
          });
        ecis.klog("ecis: ")
      };
  }
  rule fanAOn {
    select when fan airflow level re#1#  // turn on fan B
             or fan airflow level re#2# 
    pre {
      ecis = collectionEcis();
    }
    event:send({"cid": ecis[0], "attrs": {"state" : "on"} },"fan","new_status")  
  }

  rule fanBOn {
    select when fan airflow level re#2#  // turn on fan B
    pre {
      ecis = collectionEcis();

    }   
    event:send({"cid": ecis[1], "attrs": {"state" : "on"} },"fan","new_status")  
  }

  rule fanAOff {
    select when fan airflow level re#0#  // turn off fans
    pre {
      ecis = collectionEcis();
    }
    event:send({"cid": ecis[0], "attrs": {"state" : "off"} },"fan","new_status")
  }

  rule fanBOff {
    select when fan airflow level re#0#
            or fan airflow level re#1#
    pre {
      ecis = collectionEcis();
    }
    event:send({"cid": ecis[1], "attrs": {"state" : "off"} },"fan","new_status")
  }

}