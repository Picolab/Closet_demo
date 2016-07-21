ruleset closetCollection {
  meta {

    name "closet_collection"
    author "PicoLabs"
    description "General rules for closet control"

    use module b507199x5 alias wrangler
    
    logging on
    
    sharing on
    provides fan_states,outside_temp,inside_temp,temp_thresholds,temps
  }

  global {
    fan_states = function (){
      ecis = Ecis("subscriber_role","fan_level_driver");
      return = wrangler:skyQuery(ecis[0],"b507888x1.dev","fanStates",{});
      return
    };
    temps = function (){
      inside = inside_temp();
      outside = outside_temp();r
      {
        "inside": inside,
        "outside": outside
      }
    };

    outside_temp = function (){
      ecis = Ecis("subscriber_role","transmit_outside_temp").klog("ecis: ");
      temp = wrangler:skyQuery(ecis[0],"b507888x4.dev","lastTemperature",{}).klog("tempf: ");
      temp
    };
    inside_temp = function (){
      ecis = Ecis("subscriber_role","transmit_inside_temp");
      temp = wrangler:skyQuery(ecis[0],"b507888x4.dev","lastTemperature",{});
      temp
    };
    temp_thresholds = function (){
      ecis = Ecis("subscriber_role","transmit_inside_temp");
      return = wrangler:skyQuery(ecis[0],"b507888x2.dev","thresholds",{ "threshold_type" : "temperature" });
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
    Ecis = function (collection,collection_value) { 
      return = wrangler:subscriptions(unknown,collection,collection_value); 
      raw_subs = return{"subscriptions"}; // array of subs
      ecis = raw_subs.map(function( subs ){
        r = subs.values().klog("subs.values(): ");
        v = r[0];
        v{"outbound_eci"}
        });
      ecis.klog("ecis: ")
    };

    fan_collection_eci = function (){
      ecis = Ecis("subscriber_role","fan_level_driver");
      ecis
    };
}
  rule save_inside_threshold {
    select when esproto new_threshold
    pre {
      ecis = Ecis("subscriber_role","transmit_inside_temp");
    }
    {
      event:send({"cid": ecis[0] },"esproto","new_threshold")
        with attrs = event:attrs();
    }
    always {
      log "Setting threshold value for inside_temp";
    }
  }

  rule logicallyFanOn {
    select when esproto threshold_violation threshold_bound re#upper#
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
    if (inside > outside) then
    {
      event:send({"cid": fan_driver[0] },"fan","airflow")
        with attrs = {
          "level" : airflow_level
        };
    } 
    fired {
      log "turned on fans with airflow level @ " + airflow_level;
    }
    else {
      log "failed to turn on its to hot outside."
    }
  }

    rule logicallyFanOff {
    select when esproto threshold_violation threshold_bound re#lower#
    pre {
      airflow_level = 0;
      fan_driver = fan_collection_eci();
    }
    {
      event:send({"cid": fan_driver[0] },"fan","airflow")
        with attrs = {
          "level" : airflow_level
        };
    } // fan is off
    always {
      log "turned off fans with airflow level @ " + airflow_level;
    }
  }
}