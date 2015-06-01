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

-(NSMenuItem*)menuItemForAccessory:(HKBAccessory*)accessory{
	NSMenuItem *item = nil;
	
	for (NSMenuItem *menuItem in self.lightsMenu.itemArray) {
		HKBAccessory *menuAccessory = [menuItem representedObject];
		if (menuAccessory == accessory) {
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
	[[[LFXClient sharedClient] localNetworkContext].allLightsCollection addLightCollectionObserver:self];
}



#pragma mark LFXLightCollectionObserver

-(void)lightCollection:(LFXLightCollection *)lightCollection didAddLight:(LFXLight *)light{
	[self addLight:light];
}
-(void)lightCollection:(LFXLightCollection *)lightCollection didRemoveLight:(LFXLight *)light{
	[self removeLight:light]; // TODO add this to -didBecomeUnAvailable as well
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


