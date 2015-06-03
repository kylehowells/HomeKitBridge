//
//  AppDelegate.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 11/10/2014.
//  Copyright (c) 2014 Kyle Howells. All rights reserved.
//

#import "AppDelegate.h"
#import "LaunchAtLoginController.h"
#import "HKBDiscoveryService.h"
#import "NSArray+Map.h"



@interface AppDelegate () <HKBDiscoveryServiceDelegate>
@property (weak) IBOutlet NSWindow *window; // Window left in case I want to add UI at any point
@end




@implementation AppDelegate{
	// [HKBDiscoveryService]
	NSArray *discoveryServices;

	// Menu bar item
	NSStatusItem *statusItem;

	// {service.name : NSMenu}
	NSMutableDictionary *serviceMenus;
	
	NSMutableDictionary *accessoryMenuItems;
	
	LaunchAtLoginController *loginController;
	NSMenuItem *autorunItem;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Create variables
	serviceMenus = [NSMutableDictionary dictionary];
	accessoryMenuItems = [NSMutableDictionary dictionary];
	
	discoveryServices = [[HKBDiscoveryService allServices] mapObjectsUsingBlock:^id(Class class, NSUInteger index){
		return [[class alloc] init];
	}];
	
	loginController = [[LaunchAtLoginController alloc] init];
	
	
	// Create status bar item
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	[statusItem setTitle:@"HKB"]; // HKB = HomeKit Bridge
	[statusItem setHighlightMode:YES];
	statusItem.menu = [[NSMenu alloc] init];
	
	
	// Start Monitoring
	for (HKBDiscoveryService *service in discoveryServices) {
		NSMenuItem *serviceMenuItem = [[NSMenuItem alloc] init];
		[serviceMenuItem setTitle:service.displayName];
		
		NSMenu *submenu = [[NSMenu alloc] initWithTitle:service.displayName];
		[serviceMenuItem setSubmenu:submenu];
		serviceMenus[service.displayName] = submenu;
		
		[statusItem.menu addItem:serviceMenuItem];
		
		service.delegate = self;
		[service startDiscovering];
	}
	
	[statusItem.menu addItem:[NSMenuItem separatorItem]];
	autorunItem = [[NSMenuItem alloc] initWithTitle:@"Launch at login" action:@selector(autoLaunchPressed) keyEquivalent:@""];
	[self updateAutoLaunch];
	
	NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
	[quitItem setTarget:[NSApplication sharedApplication]];
	[statusItem.menu addItem:quitItem];
}




#pragma mark - HKBDiscoveryServiceDelegate

-(void)discoveryService:(HKBDiscoveryService *)service didDiscoverAccessory:(HKBAccessory *)accessory{
	NSMenuItem *menuItem = [service createMenuItemForAccessory:accessory];
	accessoryMenuItems[accessory.serialNumber] = menuItem;
	
	NSMenu *menu = serviceMenus[service.displayName];
	
	if ([menu.itemArray containsObject:menuItem] == NO) {
		[menu addItem:menuItem];
	}
}
-(void)discoveryService:(HKBDiscoveryService *)service didLoseAccessory:(HKBAccessory *)accessory{
	NSMenuItem *menuItem = accessoryMenuItems[accessory.serialNumber];
	
	if (menuItem) {
		NSMenu *menu = serviceMenus[service.displayName];
		[menu removeItem:menuItem];
		
		[accessoryMenuItems removeObjectForKey:accessory.serialNumber];
	}
}







#pragma mark - Auto launch methods

-(BOOL)autoLaunch{
	id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"AutoLaunch"];
	return (object ? [object boolValue] : YES);
}
-(void)setAutoLaunch:(BOOL)autoLaunch{
	[[NSUserDefaults standardUserDefaults] setBool:autoLaunch forKey:@"AutoLaunch"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self updateAutoLaunch];
}

-(void)updateAutoLaunch{
	if ([self autoLaunch]) {
		if (![loginController launchAtLogin]) {
			[loginController setLaunchAtLogin:YES];
		}
		
		[autorunItem setState:NSOnState];
	}
	else {
		if ([loginController launchAtLogin]) {
			[loginController setLaunchAtLogin:NO];
		}
		
		[autorunItem setState:NSOffState];
	}
}

-(void)autoLaunchPressed{
	if (autorunItem.state == NSOnState) {
		[self setAutoLaunch:NO];
	}
	else {
		[self setAutoLaunch:YES];
	}
}

@end


