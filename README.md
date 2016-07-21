# Closet_demo
Closet demo for OpenWest 2016. Demonstrating Picos
# Scenario
You have an isolated closet with servers inside you want to keep cool. 
# IoT Solution
Two wireless temperature sensors, two fans, a Raspberry Pi and some KRL.
# Picos
Persistent Compute Objects(Picos) are a data structure to give analog objects a digital finger print. In KRL Picos reflect a real objects state, Picos also give things the ability to be changed digitally, bridging the gap between devices and the internet.
# Implementation 
There is a Pico created for each elament, fanA, fanB, inside_esproto, outside_esproto. Each Pico belongs to a collection acording to there functionality. fanA Pico, fanB Pico to a fan_collection Pico. inside_esproto Pico, outside_esproto Pico, fan_collection Pico to closet_collection Pico.
![alt tag](https://raw.githubusercontent.com/Picolab/Closet_demo/master/Pico_system.png)
fanController.krl is the rulesets installed in fanA and fanB Picos. this rule has a varible that needs to be updated to the url of the device used to control the coordinating fan. fancollection.krl is the rulesets insalled in fan_collection Pico. closet_collection.krl is the rulesets installed in the closet_collection Pico. outside_esproto Pico and inside_esproto Pico each have esproto_event_router.krl and esprotoTemp.krl rulesets installed.   
# Getting Started with Pico system
Picolabs documentation https://picolabs.atlassian.net/wiki/
	-Go to http://devtools.picolabs.io/index.html and create an account and log in.
	-Go to About This Pico and create a new child pico with name of closet_collection. use this method to duplicate the system above.
