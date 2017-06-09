ruleset fanController {
  meta {

    name "fan_controller"
    author "PicoLabs"
    //description "General rules for Fan control"

    //use module wrangler
    
    logging on
    
    shares fan_state, __testing
    provides fan_state, __testing
  }

  global {

__testing = { "queries": [ { "name": "fan_state" } ],
                  "events": [ 
            { "domain": "fan", "type": "new_status",
                                "attrs": ["state"] },
            { "domain": "fan", "type": "set_pin",
                                "attrs": ["pin" ] } ] }

    fan_state = function (){
      {
        "pin" : gpio:digitalRead(get_pin())
      }
    };
    get_pin = function(){
       ent:pin.defaultsTo(17)
    }
}

  rule fanOn {
    select when fan new_status state re#on#
    pre {}
      gpio:digitalWrite(get_pin(),1) 
    always {
      null.klog("turning on fan at pin " + get_pin());
    }
  }

  rule fanOff {
    select when fan new_status state re#off#
    pre {}
      gpio:digitalWrite(get_pin(),0) 
    always {
      null.klog("turning off fan at pin " + get_pin());
    }
  }

  rule setPin {
    select when fan set_pin
    pre {
      pin = event:attr("pin");
      }
     noop();
    always {
      null.klog("setting pin");
      ent:pin := pin;
    }
  }

}