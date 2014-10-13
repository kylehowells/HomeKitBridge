//
//  AppDelegate.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 11/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import <LIFXKit/LIFXKit.h>

#import "AppDelegate.h"
#import "HKBLightAccessory.h"


@interface AppDelegate () <LFXLightCollectionObserver, HKBLightDelegate>
@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *lightsMenu;

@property (nonatomic, strong) NSMutableDictionary *lights;


@property (nonatomic, strong) NSMutableArray *array;
@end



@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.lights = [NSMutableDictionary dictionary];
	
	
	
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[self.statusItem setTitle:@"HKB"]; // HKB = HomeKit Bridge
	[self.statusItem setHighlightMode:YES];
	
	self.statusItem.menu = [[NSMenu alloc] init];
	
	
	self.lightsMenu = [[NSMenu alloc] initWithTitle:@"Lights"];
	NSMenuItem *lightsMenuItem = [[NSMenuItem alloc] init];
	[lightsMenuItem setTitle:@"Lights"];
	[lightsMenuItem setSubmenu:self.lightsMenu];
	
	[self.statusItem.menu addItem:lightsMenuItem];
	
	
	
//	HKBAccessory *accessory = [[HKBAccessory alloc] initWithInformation:@{ @"name" : @"Test Device",
//																		   @"serialNumber" : @"A2EG5VB6123",
//																		   @"manufacturer" : @"Kyle Tech",
//																		   @"model" : @"V1 Bridge"}];
//	
//	self.array = [[NSMutableArray alloc] initWithObjects:accessory, nil];
//	accessory = nil;
//	
//	NSLog(@"Accessory: %@", accessory);
//	NSLog(@"array: %@", self.array);
//	
//	[self.array removeAllObjects];
//	
//	NSLog(@"array: %@", self.array);
	
	
	// Everything above this point in the code is generalisable, for this point it is an example using the LIFX SDK.
	[HKBLightAccessory setDefaultInformation:@{NameKey: @"Light",
											   ModelKey: @"Wifi bulb, White v1",
											   ManufacturerKey: @"LIFX"}];
	
	[[[LFXClient sharedClient] localNetworkContext].allLightsCollection addLightCollectionObserver:self];
}




#pragma mark - HKBLightDelegate

-(void)setLight:(HKBLightAccessory *)light powerState:(BOOL)_powerState {
	NSString *deviceID = [[self.lights allKeysForObject:light] firstObject];
	
	LFXPowerState powerState = _powerState ? LFXPowerStateOn : LFXPowerStateOff;
	
	LFXLight *lfxLight = [[[LFXClient sharedClient] localNetworkContext].allLightsCollection lightForDeviceID:deviceID];
	[lfxLight setPowerState:powerState];
}

-(void)setLight:(HKBLightAccessory *)light hue:(NSInteger)hue {
	NSString *deviceID = [[self.lights allKeysForObject:light] firstObject];
	LFXLight *lfxLight = [[[LFXClient sharedClient] localNetworkContext].allLightsCollection lightForDeviceID:deviceID];
	
	LFXHSBKColor *currentColor = [lfxLight color];
	LFXHSBKColor *newColor = [LFXHSBKColor colorWithHue:hue saturation:currentColor.saturation brightness:currentColor.brightness];
	
	[lfxLight setColor:newColor];
}
-(void)setLight:(HKBLightAccessory *)light brightness:(NSInteger)brightness {
	CGFloat _brightness = brightness * 0.01;
	
	NSString *deviceID = [[self.lights allKeysForObject:light] firstObject];
	LFXLight *lfxLight = [[[LFXClient sharedClient] localNetworkContext].allLightsCollection lightForDeviceID:deviceID];
	
	LFXHSBKColor *currentColor = [lfxLight color];
	LFXHSBKColor *newColor = [LFXHSBKColor colorWithHue:currentColor.hue saturation:currentColor.saturation brightness:_brightness];
	
	[lfxLight setColor:newColor];
}
-(void)setLight:(HKBLightAccessory *)light saturation:(NSInteger)saturation {
	CGFloat _saturation = saturation * 0.01;
	
	NSString *deviceID = [[self.lights allKeysForObject:light] firstObject];
	LFXLight *lfxLight = [[[LFXClient sharedClient] localNetworkContext].allLightsCollection lightForDeviceID:deviceID];
	
	LFXHSBKColor *currentColor = [lfxLight color];
	LFXHSBKColor *newColor = [LFXHSBKColor colorWithHue:currentColor.hue saturation:_saturation brightness:currentColor.brightness];
	
	[lfxLight setColor:newColor];
}





#pragma mark LFXLightCollectionObserver

-(void)lightCollection:(LFXLightCollection *)lightCollection didAddLight:(LFXLight *)light{
	[self addLight:light];
}
-(void)lightCollection:(LFXLightCollection *)lightCollection didRemoveLight:(LFXLight *)light{
	[self removeLight:light];
}



-(void)addLight:(LFXLight*)lifxLight{
	if (self.lights[lifxLight.deviceID] != nil) { return; }
	
	// Settings
	HKBLightCharacteristics lightAbilities = (HKBLightCharacteristicBrightness | HKBLightCharacteristicHue | HKBLightCharacteristicSaturation);
	NSDictionary *information = @{NameKey : lifxLight.label, SerialNumberKey : lifxLight.deviceID}; //Can -label be nil? This will crash if it is
	
	// Create light
	HKBLightAccessory *light = [[HKBLightAccessory alloc] initWithInformation:information andCharacteristics:lightAbilities];
	light.delegate = self;
	
	// Add it
	self.lights[lifxLight.deviceID] = light;
}
-(void)removeLight:(LFXLight*)lifxLight{
	if (self.lights[lifxLight.deviceID] == nil) { return; }
	
	// Get rid of it
	[self.lights removeObjectForKey:lifxLight.deviceID];
}

@end





















/*
//
//  AppDelegate.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 11/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import <LIFXKit/LIFXKit.h>
#import "HKBLightAccessoryLIFX.h"

#import "AppDelegate.h"

@interface AppDelegate (LIFX) <LFXLightCollectionObserver>
-(void)setupLIFXMonitoring;
@end



@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window; // Window left in case I want to add UI at any point

// Menu bar item
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *lightsMenu;

// Lights dictionary. { serialNumber : lightAccessoryObject }
@property (nonatomic, strong) NSMutableDictionary *lights;


-(NSMenuItem*)createMenuItemForAccessory:(HKBAccessory*)_accessory;
-(NSMenuItem*)menuItemForAccessory:(HKBAccessory*)_accessory;
@end



@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Set defaults
	[HKBLightAccessory setDefaultInformation:@{NameKey:@"Light", ModelKey:@"WiFi Bulb", ManufacturerKey:@"Kyle Tech"}];
	
	
	// Create variables
	self.lights = [NSMutableDictionary dictionary];
	
	// Create status bar item
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[self.statusItem setTitle:@"HKB"]; // HKB = HomeKit Bridge
	[self.statusItem setHighlightMode:YES];
	self.statusItem.menu = [[NSMenu alloc] init];
	
	
	// Create a submenu where we'll put the lights
	NSMenuItem *lightsMenuItem = [[NSMenuItem alloc] init];
	[lightsMenuItem setTitle:@"Lights"];
	
	self.lightsMenu = [[NSMenu alloc] initWithTitle:@"Lights"];
	[lightsMenuItem setSubmenu:self.lightsMenu];
	
	[self.statusItem.menu addItem:lightsMenuItem];
	
	
	// LIFX specific stuff in here
	[self setupLIFXMonitoring];
}




-(NSMenuItem*)createMenuItemForAccessory:(HKBAccessory*)_accessory{
	NSString *title = [_accessory.name stringByAppendingFormat:@" - PIN: %@", _accessory.passcode];
	NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:_accessory.name];
	return menuItem;
}

-(NSMenuItem*)menuItemForAccessory:(HKBAccessory*)_accessory{
	NSMenuItem *item = nil;
	
	for (NSMenuItem *menuItem in self.lights) {
		HKBAccessory *accessory = [menuItem representedObject];
		if (accessory == _accessory) {
			item = menuItem;
			break;
		}
	}
	
	return item;
}

@end










@implementation AppDelegate (LIFX)

-(void)setupLIFXMonitoring{
	// Everything above this point in the code is generalisable, for this point it is an example using the LIFX SDK.
	[HKBLightAccessory setDefaultInformation:@{NameKey:@"Light", ModelKey:@"White Wifi bulb v1", ManufacturerKey:@"LIFX"}];
	
	[[[LFXClient sharedClient] localNetworkContext].allLightsCollection addLightCollectionObserver:self];
}




#pragma mark LFXLightCollectionObserver

-(void)lightCollection:(LFXLightCollection *)lightCollection didAddLight:(LFXLight *)light{
	[self addLight:light];
}
-(void)lightCollection:(LFXLightCollection *)lightCollection didRemoveLight:(LFXLight *)light{
	[self removeLight:light];
}


-(void)addLight:(LFXLight*)lifxLight{
	if (self.lights[lifxLight.deviceID] != nil) { return; }
	
	// Create light
	HKBLightAccessoryLIFX *light = [[HKBLightAccessoryLIFX alloc] initWithLightBulb:lifxLight];
	
	// Add it
	self.lights[lifxLight.deviceID] = light;
	
	// Create menu item
	NSMenuItem *menuItem = [self createMenuItemForAccessory:light];
	[menuItem setRepresentedObject:light];
	[self.lightsMenu addItem:menuItem];
}
-(void)removeLight:(LFXLight*)lifxLight{
	if (self.lights[lifxLight.deviceID] == nil) { return; }
	
	// Remove menu item
	NSMenuItem *menuItem = [self menuItemForAccessory:self.lights[lifxLight.deviceID]];
	[self.lightsMenu removeItem:menuItem];
	
	// Get rid of it
	[self.lights removeObjectForKey:lifxLight.deviceID];
}

@end

*/

