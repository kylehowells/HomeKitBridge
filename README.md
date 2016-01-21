Demo
=============
https://www.youtube.com/watch?v=n1Yr9xclh8w




HomeKitBridge
=============

An API designed to easily allow you to hook up existing devices and services to HomeKit using the private "HomeKit Accessory" Framework bundled with the HomeKit Accessory Simulator.
Basically this just wraps the private HomeKitAccessoryKit framework API's in a way designed to bridge across to other products APIs more easily.

All accessories are their own accessory with this API. It doesn't simulate a HomeKit "bridge" but instead pretends all the accessories natively support HomeKit.

This doesn't persist accessories to file. This is on purpose as it is presumed you'll be using an existing API to discover and setup devices each time.

Accessories do cache their "Transport" object to file though, as you can see in HKBTransportCache.m. The reason for this is because each time a "transport" object is created it generates a new password (and ID?). If it wasn't saved to file then on your iPhone you'd have to reconnect to and setup all your devices each time this application starts up.

Instead the "Transport" objects are saved to file before they have any accessories or characteristics attached to them (so those don't save as well).

As it is, it appears the connection setup between the accessory and HomeKit on your phone appears to survive restarting this application. 



Supported Devices
=============
 - [LIFX Wifi Lightbulbs](http://lifx.co)


Building
=============

Make sure you have the **HomeKit Accessory Simulator** installed in **"/Applications"**
The project reaches inside it and grabs the private framework as it builds.

The easiest way to get the HomeKit simulator is to go in Xcode to the menu bar > Xcode > Open Developer Tool > More Developer Tools... > And then download "**Hardware IO Tools for Xcode 6.3**".


On your iOS device
=============
To setup the HomeKit accessories on your device you'll need a HomeKit app. Apple doesn't provide one and I don't know of any in the AppStore. I'm currently using this one: https://github.com/KhaosT/HomeKit-Demo


TODO
=============
Support other device types besides lights.

Documentation (I'll write some soon (I mean it this time)).
For now just read "HKBAccessory.h" for an overview. Look in AppDelegate.m to see how to use the API once everything is in place (very simple). Look at "HKBLightAccessory" to see an example of how to write an accessory subclass.

The HKBLightAccessory class is abstract and doesn't link to any devices API directly. It is designed to be subclassed so that you can easily bridge different light bulbs SDKs to HomeKit. 

Instead look at HKBLightAccessoryLIFX.m to see a self contained subclass that links a light object from LIFX's API to the HomeKit API.



Thanks
=============

 - https://github.com/KhaosT/HomeKitBridge : As example of how to use the framework
 - https://github.com/KhaosT/HomeKitLogicalSimulator : As example of how to use the framework
 - http://www.hopperapp.com : For letting me reverse the HomeKit simulator and see how it uses the framework
 - http://www.cycript.org : For letting me test I understood what was going on by poking around inside the HomeKit simulator while it was running.

