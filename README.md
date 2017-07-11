# Closet_demo
Closet demo for OpenWest 2017. Demonstrating Picos
# Scenario
You have an isolated closet with servers inside you want to keep cool. 
# IoT Solution
Two wireless temperature sensors, two fans, a Raspberry Pi and some KRL.
# Picos
Persistent Compute Objects(Picos) are a data structure to give analog objects a digital finger print. In KRL, Picos reflect a real object's state, giving things the ability to be changed digitally, bridging the gap between devices and the internet.
# Note
This demo is an update and adaptation of the closet demo for OpenWest 2016, originally designed on the classic Pico engine and now ported to the Node Pico Engine (NPE). Also note, the organization of Picos into collections and their rulesets can be organized in any way that makes sense to you as a developer. If an outside user wanted to interact with the closet demo as a part of an IoT system much larger than what we have portrayed here, they need only interact with the closet_collection Pico, using its events and rules as an api. This encapsulates the implementation details and provides a user friendly way to link IoT devices to each other.
# Implementation 
There is a Pico created for each element, including fanA, fanB, the inside Wovyn device and the outside Wovyn device. The Wovyn devices are dedicated to monitoring inside and outside temperatures. Each Pico belongs to a collection according to their functionality. For example, the fanA and fanB Picos belong to a fan_collection Pico. Both Wovyn devices belong to the closet_collection Pico. Since the fan collection Pico is also a part of the closet, it too has a relationship with closet collection pico.
![alt tag](https://raw.githubusercontent.com/Picolab/Closet_demo/master/Device%20Shadow%20Diagram%20V2.png)
fanControllerNPE.krl is the ruleset installed on fanA and fanB Picos. fancollectionNPE.krl is the ruleset insalled in the fan_collection Pico. closet_collectionNPE.krl is the ruleset installed in the closet_collection Pico. The Wovyn Picos each have wovyn_event_routerNPE.krl installed, whereas the inside Wovyn device is the only Pico with wovyn_device.krl installed, as we chose that Pico to monitor temperature threshold violations. Using a module we added to the Node Pico Engine on our raspberry pi, the fan picos can physically control the fans through the pi's pins and a breadboard.
# Getting Started with Pico system
Picolabs documentation https://picolabs.atlassian.net/wiki/
To download the Node Pico Engine and become a krl developer, follow the instructions on the quick start page https://picolabs.atlassian.net/wiki/display/docs/Pico+Engine+Quickstart
