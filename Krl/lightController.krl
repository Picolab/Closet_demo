ruleset lightController {
  meta {
    name "light_controller"
    author "PicoLabs"
    
    use module wrangler
    
    logging on
    
    shares light_state, __testing
    provides light_state, __testing
  }

  global {

__testing = { "queries": [ { "name": "light_state" } ],
                  "events": [ 
{ "domain": "light", "type": "new_status",
                                "attrs": ["state"] },
{ "domain": "light", "type": "set_pin",
                                "attrs": ["pin" ] } ] }


    light_state = function (){
      {
        "pin" : gpio:digitalRead(ent:pin)
      }
    };
    get_pin = function(){
       ent:pin.defaultsTo(22)
    }
}

  rule lightOn {
    select when light new_status state re#on#
    pre {}
      gpio:digitalWrite(get_pin(),1) 
    always {
      null.klog("turning on light at pin " + get_pin());
    }
  }

  rule lightOff {
    select when light new_status state re#off#
    pre {}
      gpio:digitalWrite(get_pin(),0) 
    always {
      null.klog("turning off light at pin " + get_pin());
    }
  }

  rule setPin {
    select when light set_pin
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

