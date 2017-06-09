ruleset closetCollection {
  meta {

    name "closet_collection"
    author "PicoLabs"
    //description "General rules for closet control"

    use module io.picolabs.wrangler.common alias common
    use module Subscriptions
    
    logging on
    
    shares __testing,fan_states,outside_temp,inside_temp,temp_thresholds,temps
    provides fan_states,outside_temp,inside_temp,temp_thresholds,temps
  }

  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ { "domain": "test", "type": "something",
                                "attrs": [ ] } ] }

    fan_states = function (){
      ecis = EcisFromParams("subscriber_role","fan_level_driver");
      return = common:skyQuery(ecis[0],"fanCollection","fanStates",{});
      return
    };
    temps = function (){
      inside = inside_temp();
      outside = outside_temp();
      {
        "inside": inside,
        "outside": outside
      }
    };

    outside_temp = function (){
      ecis = EcisFromParams("subscriber_role","transmit_outside_temp").klog("ecis: ");
      temp = common:skyQuery(ecis[0],"wovyn_router","lastTemperature",{}).klog("tempf: ");
      temp
    };
    inside_temp = function (){
      ecis = EcisFromParams("subscriber_role","transmit_inside_temp");
      temp = common:skyQuery(ecis[0],"wovyn_router","lastTemperature",{});
      temp
    };
    temp_thresholds = function (){
      ecis = EcisFromParams("subscriber_role","transmit_inside_temp");
      return = common:skyQuery(ecis[0],"wovyn_device","thresholds",{ "threshold_type" : "temperature" });
      return
    };
    lower_threshold = function (){
      thresholds = temp_thresholds();
      thresholds_lower = thresholds{["limits","lower"]};
      thresholds_lower
    };
    upper_threshold = function (){
      thresholds = temp_thresholds();
      thresholds_upper = thresholds{["limits","upper"]};
      thresholds_upper
    };
    //private
    Ecis = function () { 
      return = Subscriptions:subscriptions(["attributes","subscriber_role"],"receive_temp").klog("subscriptions:   "); 
      raw_subs = return;//{"subscriptions"}; // array of subs
      ecis = raw_subs.map(function( subs ){
        r = subs.values().klog("subs.values(): ");
        v = r[0].klog("subscription we want");
        v.attributes.outbound_eci
        });
      ecis.klog("ecis: ")
    };

    EcisFromParams = function (collection,filter) { 
      return = Subscriptions:subscriptions(["attributes",collection],filter).klog("subscriptions:   "); 
      raw_subs = return;//{"subscriptions"}; // array of subs
      ecis = raw_subs.map(function( subs ){
        r = subs.values().klog("subs.values(): ");
        v = r[0].klog("subscription we want");
        v.attributes.outbound_eci
        });
      ecis.klog("ecis: ")
    };

    fan_collection_eci = function (){
      ecis = EcisFromParams("subscriber_role","fan_level_driver");
      ecis
    };
}
  rule save_inside_threshold {
    select when wovyn new_threshold
    pre {
      ecis = Ecis("subscriber_role","transmit_inside_temp");
    }
    every {
      event:send({"eci": ecis[0],"eid" : random:integer(100,2000) , "attrs": event:attrs(), "domain": "wovyn", "type": "new_threshold" })
    }
    always {
      "Setting threshold value for inside_temp".klog(".");
    }
  }

  rule logicallyFanOn {
    select when wovyn threshold_violation threshold_bound re#upper#
    pre {
      data = event:attr("reading").klog("data: ").decode();
      inside = data{"temperatureF"}.klog("inside temp: ");
      outside = outside_temp().klog("outside temp: ");
      thresholds = temp_thresholds().klog("inside temp thresholds: ");
      thresholds_upper = thresholds{["limits","upper"]}.klog("upper_threshold: ");
      thresholds_diff = inside - thresholds_upper;
      airflow_level = (thresholds_diff > 3) => 2 | 1;
      fan_driver = fan_collection_eci();
    }
    if (inside > outside) then every
    {
      event:send({"eci": fan_driver[0],"eid" : random:integer(100,2000) , "attrs": {"level": airflow_level}, "domain": "fan", "type": "airflow" })
    } 
    fired {
      airflow_level.klog("turned on fans with airflow level @ ");
    }
    else {
      "failed to turn on its to hot outside".klog(".")
    }
  }

  rule logicallyFanOff {
    select when wovyn threshold_violation threshold_bound re#lower#
    pre {
      airflow_level = 5;
      fan_driver = fan_collection_eci();
    }
    if (true) then every {
      event:send({"eci": fan_driver[0].klog("fan_driver"), "eid" : random:integer(100,2000).klog("random eid "), "domain": "fan".klog("domain "), "type": "airflow".klog("type ") , "attrs": {"level" : airflow_level}.klog("attrs ") }.klog("event:send param "))
    } 
    always {
      airflow_level.klog("turned off fans with airflow level @ ");
    }
  }
}
