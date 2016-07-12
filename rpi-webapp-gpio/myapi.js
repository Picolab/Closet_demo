/**
 * myapi.js
 * 
 * @version 1.1 - April 2015
 *
 * 
 * DESCRIPTION:
 * an application to demonstrate running a node 
 * API Appserver on a Raspberry Pi to access GPIO I/O
 * Uses the Express and wiringPi node packages. 
 * 
 * 
 * @throws none
 * @see nodejs.org
 * @see express.org
 * 
 * @author Ceeb
 * (C) 2015 PINK PELICAN NZ LTD
 */

var http      = require('http');
var express   = require('express');
//var gpio      = require('pi-gpio');
var gpioUtil = require('pi-gpioutil');
//var gpioUtil = require('wiring-pi');
var app       = express();

// input port objects for our example
var inputs = [    { pin: '4', gpio: '23', value: null, thing: 'FanA' },
                  { pin: '5', gpio: '24', value: null, thing: 'FanB' },
                  { pin: '6', gpio: '25', value: null, thing: 'Light' }
                ];

// -----------------------------------------------------------------------
// open GPIO ports
var i;
for (i in inputs) {
  console.log('opening GPIO port ' + inputs[i].gpio + ' on pin ' + inputs[i].pin + ' as input');
  gpioUtil.export(inputs[i].gpio, 'out', function(err) {
    if (err) {
      throw err;
    }
  }); // gpio.export
} // end for loop

// ------------------------------------------------------------------------
// read and store the GPIO inputs twice a second
setInterval( function () {
  gpioUtil.read(inputs[0].pin, function(err, stdout, stderr, value) {
    if (err) {
      throw err;
    }
    console.log('read pin ' + inputs[0].pin + ' value = ' + value);
    // update the inputs object
    inputs[0].value = value;
  });

  gpioUtil.read(inputs[1].pin, function(err, stdout, stderr, value) {
    if (err) {
      throw err;
    }
    console.log('read pin ' + inputs[1].pin + ' value = ' + value);
    inputs[1].value = value;
  });

  gpioUtil.read(inputs[2].pin, function(err, stdout, stderr, value) {
    if (err) {
      throw err;
    }
    console.log('read pin ' + inputs[2].pin + ' value = ' + value);
    inputs[2].value = value;
  });

}, 500); // setInterval

// ------------------------------------------------------------------------
// configure Express to serve index.html and any other static pages stored 
// in the home directory
app.use(express.static(__dirname));

// Express route for incoming requests for a single input
app.get('/inputs/:id', function (req, res) {
  var i;

  console.log('received API request for port number ' + req.params.id);
  
  for (i in inputs){
    if ((req.params.id === inputs[i].gpio)) {
      // send to client an inputs object as a JSON string
      res.send(inputs[i]);
      return;
    }
  } // for

  console.log('invalid input port');
  res.status(403).send('dont recognise that input port number ' + req.params.id);
}); // apt.get()

// Express route for incoming requests for a list of all inputs
app.get('/inputs', function (req, res) {
  // send array of inputs objects as a JSON string
  console.log('all inputs');
  res.status(200).send(inputs);
}); // apt.get()

// Express route for any other unrecognised incoming requests
app.get('*', function (req, res) {
  res.status(404).send('Unrecognised API call');
});

// Express route for put commands 
app.put('/toggle/:id', function (req, res) {
  console.log('received API put request for toggling port number ' + req.params.id);
  for (i in inputs){
    if ((req.params.id === inputs[i].gpio)) {
      inputs[i].value = inputs[i].value ? false : true;
      console.log('read pin ' + inputs[i].pin + ' value = ' + inputs[i].value);
      gpioUtil.write(inputs[i].pin,inputs[i].value,function(err, stdout, stderr, value) {
        if (err) {
          throw err;
        }
        res.status(200).send(inputs[i]);
      });
      return;
    }
  } // for
});
app.put('/fanAon', function (req, res) {
  console.log('received API put request for toggling fanA on ');
  var index = 0;
  inputs[index].value = true;
  gpioUtil.write(inputs[index].pin,inputs[index].value,function(err, stdout, stderr, value) {
        if (err) {
          throw err;
        }
        res.status(200).send(inputs[index]);
      });
      return;
});

app.put('/fanBon', function (req, res) {
  console.log('received API put request for toggling fanB on ');
  var index = 1;
  inputs[index].value = true;
  gpioUtil.write(inputs[index].pin,inputs[index].value,function(err, stdout, stderr, value) {
        if (err) {
          throw err;
        }
        res.status(200).send(inputs[index]);
      });
      return;
});

app.put('/lightOn', function (req, res) {
  console.log('received API put request for toggling light on ');
  var index = 2;
  inputs[index].value = true;
  gpioUtil.write(inputs[index].pin,inputs[index].value,function(err, stdout, stderr, value) {
        if (err) {
          throw err;
        }
        res.status(200).send(inputs[index]);
      });
      return;
});

app.put('/lightOff', function (req, res) {
  console.log('received API put request for toggling light off ');
  var index = 2;
  inputs[index].value = false;
  gpioUtil.write(inputs[index].pin,inputs[index].value,function(err, stdout, stderr, value) {
        if (err) {
          throw err;
        }
        res.status(200).send(inputs[index]);
      });
      return;
});

app.put('/fanBoff', function (req, res) {
  console.log('received API put request for toggling fanB off ');
  var index = 1;
  inputs[index].value = false;
  gpioUtil.write(inputs[index].pin,inputs[index].value,function(err, stdout, stderr, value) {
        if (err) {
          throw err;
        }
        res.status(200).send(inputs[index]);
      });
      return;
});

app.put('/fanAoff', function (req, res) {
  console.log('received API put request for toggling fanA off ');
  var index = 0;
  inputs[index].value = false;
  gpioUtil.write(inputs[index].pin,inputs[index].value,function(err, stdout, stderr, value) {
        if (err) {
          throw err;
        }
        res.status(200).send(inputs[index]);
      });
      return;
});

// Express route to handle errors
app.use(function (err, req, res, next) {
  if (req.xhr) {
    res.status(500).send('Oops, Something went wrong!');
  } else {
    next(err);
  }
}); // apt.use()

process.on('SIGINT', function() {
  var i;

  console.log("\nGracefully shutting down from SIGINT (Ctrl+C)");

  console.log("closing GPIO...");
  for (i in inputs) {
    gpioUtil.unexport(inputs[i].gpio);
  }
  process.exit();
});

// ------------------------------------------------------------------------
// Start Express App Server
//
app.listen(8000);
console.log('App Server is listening on port 8000');

