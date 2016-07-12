ruleset esproto_device {
  meta {

    name "esproto_device"
    author "PJW"
    description "General rules for ESProto system devices"

    use module b507199x5 alias wrangler
    
    logging on
    
    sharing on
    provides thresholds
  }

  global {

    // public
    thresholds = function(threshold_type) {
      threshold_type.isnull() => ent:thresholds
                               | ent:thresholds{threshold_type}
    }

    //private
    event_map = {
      "new_temperature_reading" : "temperature",
      "new_humidity_reading" : "humidity",
      "new_pressure_reading" : "pressure"
    };

    reading_map = {
      "temperature": "temperatureF",
      "humidity": "humidity",
      "pressure": "pressure"
    };

    Ecis = function () { 
      return = wrangler:subscriptions(unknown,"subscriber_role","receive_temp"); 
      raw_subs = return{"subscriptions"}; // array of subs
      ecis = raw_subs.map(function( subs ){
        r = subs.values().klog("subs.values(): ");
        v = r[0];
        v{"outbound_eci"}
        });
      ecis.klog("ecis: ")
    };

    collectionSubscriptions = function () {
        return = wrangler:subscriptions(unknown,"subscriber_role","receive_temp"); 
        raw_subs = return{"subscriptions"}; // array of subs
        //subs = raw_subs[0];
        raw_subs.klog("Subscriptions: ")
      };
  }


  // rule to save thresholds
  rule save_threshold {
    select when esproto new_threshold
    pre {
      threshold_type = event:attr("threshold_type");
      threshold_value = {"limits": {"upper": event:attr("upper_limit"),
                                    "lower": event:attr("lower_limit")
           }};
    }
    if(not threshold_type.isnull()) then noop();
    fired {
      log "Setting threshold value for #{threshold_type}";
      set ent:thresholds{threshold_type} threshold_value;
    }
  }

  rule check_threshold {
    select when esproto new_temperature_reading
             or esproto new_humidity_reading
             or esproto new_pressure_reading
    foreach event:attr("readings") setting (reading)
      pre {
        event_type = event:type().klog("Event type: ");

        // thresholds
  threshold_type = event_map{event_type}; 
  threshold_map = thresholds(threshold_type).klog("Thresholds: ");
  lower_threshold = threshold_map{["limits","lower"]}.klog("Lower threshold: ");
  upper_threshold = threshold_map{["limits","upper"]};

        // sensor readings
  data = reading.klog("Reading from #{threshold_type}: ");
  reading_value = data{reading_map{threshold_type}}.klog("Reading value for #{threshold_type}: ");
  sensor_name = data{"name"}.klog("Name of sensor: ");

        // decide
  under = reading_value < lower_threshold;
  over = upper_threshold < reading_value;
  msg = under => "#{threshold_type} is under threshold of #{lower_threshold}"
      | over  => "#{threshold_type} is over threshold of #{upper_threshold}"
      |          "";
      }
      if(  under || over ) then noop();
      fired {
  raise esproto event "threshold_violation" attributes
    {"reading": reading.encode(),
     "threshold": under => lower_threshold | upper_threshold,
     "threshold_bound": under => "lower" | "upper"
    // "message": "threshold violation: #{msg} for #{sensor_name}"
    }       

      }
  }


  // route events to all collections I'm a member of
  // change eventex to expand routed events.
  rule route_to_collections {
    select when esproto threshold_violation
             or esproto battery_level_low
    foreach Ecis() setting (eci)
      pre {
      }
      event:send({"cid": eci}, "esproto", event:type())
        with attrs = event:attrs();
  }


  rule auto_approve_pending_subscriptions {
    select when wrangler inbound_pending_subscription_added 
           //name_space re/esproto-meta/gi
    pre{
      attributes = event:attrs().klog("subcription attributes :");
      subscriptions = wrangler:subscriptions()
                        .pick("$.subscriptions")
                        .klog(">>> current subscriptions >>>>")
      ;
      declared_relationship = "device_collection";
      relationship = event:attr("relationship").klog(">>> subscription relationship >>>>");
    }
  
    if ( not relationship like declared_relationship  
      || subscriptions.length() == 0
       ) then // only auto approve the first subscription request
    {
       noop();
    }

    fired {
       log ">>> auto approving subscription: #{relationship}";
       raise wrangler event 'pending_subscription_approval'
          attributes attributes;        
    }
  }


}
