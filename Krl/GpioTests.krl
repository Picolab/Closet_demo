ruleset test {
  meta {
    use module wrangler
    shares __testing
  }
  global {
    __testing = { "queries": [ { "name": "__testing" } ],
                  "events": [ { "domain": "test", "type": "something",
                                "attrs": [ ] },
{ "domain": "test", "type": "FanLeft",
                                "attrs": [ ] },
{ "domain": "test", "type": "FanRight",
                                "attrs": [ ] },
{ "domain": "test", "type": "Light",
                                "attrs": [ ] },
{ "domain": "test", "type": "Phanns",
                                "attrs": [ ] },
{ "domain": "test", "type": "mapIndex",
                                "attrs": [ ] } ] }

    getself = function(){wrangler:myself()}
  }

  rule test_one{
    select when test something
    pre{
      a = event:domain().klog("Event type: ");
      b = event:type().klog("Event type: ");
    }every{
    gpio:digitalWrite(17,0)//fanleft
    gpio:digitalWrite(27,0)//fanright
    gpio:digitalWrite(22,0)//light
    }
    fired{
    }
  }

  rule FanLeft{
    select when test FanLeft
    pre{
      toggle = gpio:digitalRead(17);
    }
    gpio:digitalWrite(17, 1 - toggle ) // fanleft
    fired{
    }
  }

  rule FanRight{
    select when test FanRight
   pre{
      toggle = gpio:digitalRead(27);
    }
    gpio:digitalWrite(27, 1 - toggle ) 
    fired{
    }
  }

  rule Phanns{
    select when test Phanns
   pre{
      toggleLeft  = gpio:digitalRead(17);
      toggleRight = gpio:digitalRead(27);
    }every{
    gpio:digitalWrite(17, 1 - toggleLeft ) 
    gpio:digitalWrite(27, 1 - toggleRight )
    } 
    fired{
    }
  }

  rule Light{
    select when test Light
    pre{
      toggle = gpio:digitalRead(22);
    }
    gpio:digitalWrite(22, 1 - toggle ) 
    fired{
    }
  }

  rule mapIndexing{
    select when test mapIndex
    pre{
      a = {"id": "someID", "eci": " someECI", "name": "Pico's name"};
      b = a["id"].klog("a[id]: ");
      c = a["eci"].klog("a[eci]");
      d = a["name"].klog("a[name]");
    }
    send_directive("success!?",{"a[id]": b, "a[eci]": c, "a[name]": d}) 
    fired{
    }
  }
}
