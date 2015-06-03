//
//  AppDelegate.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 11/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import "AppDelegate.h"
#import "HKBDiscoveryService.h"
#import "NSArray+Map.h"



@interface AppDelegate () <HKBDiscoveryServiceDelegate>
@property (weak) IBOutlet NSWindow *window; // Window left in case I want to add UI at any point

/// [HKBDiscoveryService]
@property (nonatomic, strong) NSArray *discoveryServices;


// Menu bar item
@property (nonatomic, strong) NSStatusItem *statusItem;
/// {service.name : NSMenu}
@property (nonatomic, strong) NSMutableDictionary *serviceMenus;

@property (nonatomic, strong) NSMutableDictionary *accessoryMenuItems;
@end




@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Create variables
	self.serviceMenus = [NSMutableDictionary dictionary];
	self.accessoryMenuItems = [NSMutableDictionary dictionary];
	
	self.discoveryServices = [[HKBDiscoveryService allServices] mapObjectsUsingBlock:^id(Class class, NSUInteger index){
		return [[class alloc] init];
	}];
	
	
	// Create status bar item
	self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[self.statusItem setTitle:@"HKB"]; // HKB = HomeKit Bridge
	[self.statusItem setHighlightMode:YES];
	self.statusItem.menu = [[NSMenu alloc] init];
	
	
	// Start Monitoring
	for (HKBDiscoveryService *service in self.discoveryServices) {
		NSMenuItem *serviceMenuItem = [[NSMenuItem alloc] init];
		[serviceMenuItem setTitle:service.displayName];
		
		NSMenu *submenu = [[NSMenu alloc] initWithTitle:service.displayName];
		[serviceMenuItem setSubmenu:submenu];
		self.serviceMenus[service.displayName] = submenu;
		
		[self.statusItem.menu addItem:serviceMenuItem];
		
		service.delegate = self;
		[service startDiscovering];
	}
}




#pragma mark - HKBDiscoveryServiceDelegate

-(void)discoveryService:(HKBDiscoveryService *)service didDiscoverAccessory:(HKBAccessory *)accessory{
	NSMenuItem *menuItem = [service createMenuItemForAccessory:accessory];
	self.accessoryMenuItems[accessory.serialNumber] = menuItem;
	
	NSMenu *menu = self.serviceMenus[service.displayName];
	
	if ([menu.itemArray containsObject:menuItem] == NO) {
		[menu addItem:menuItem];
	}
}
-(void)discoveryService:(HKBDiscoveryService *)service didLoseAccessory:(HKBAccessory *)accessory{
	NSMenuItem *menuItem = self.accessoryMenuItems[accessory.serialNumber];
	
	if (menuItem) {
		NSMenu *menu = self.serviceMenus[service.displayName];
		[menu removeItem:menuItem];
		
		[self.accessoryMenuItems removeObjectForKey:accessory.serialNumber];
	}
}

@end


