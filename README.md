HomeKitBridge
=============

An API designed to easily allow you to hook up existing devices and services to HomeKit using the private "HomeKit Accessory" Framework bundled with the HomeKit Accessory Simulator.
Basically just wraps the private HomeKitAccessoryKit framework API's in a way designed to bridge across to other products APIs.


Building
=============
Make sure you have the "HomeKit Accessory Simulator" installed in /Applications
The project reaches inside it and grabs the private framework as it builds.


TODO
=============
Documentation, I'll write some tomorrow.
For now just read HKBAccessory.h and look in AppDelegate.m and HKBLightAccessoryLIFX.m to see how to use this wrapper.


Thanks
=============
https://github.com/KhaosT/HomeKitBridge (as example of how to use the framework)
https://github.com/KhaosT/HomeKitLogicalSimulator (as example of how to use the framework)
http://www.hopperapp.com (For letting me reverse the HomeKit simulator and see how it uses the framework)
http://www.cycript.org (For letting me test I understood what was going on, and to poke around inside the sim while it was running)

