//
//  HKBLIFXDiscoveryService.m
//  HomeKitBridge
//
//  Created by Kyle Howells on 02/06/2015.
//  Copyright (c) 2015 Kyle Howells. All rights reserved.
//

#import "HKBLIFXDiscoveryService.h"

#import <LIFXKit/LIFXKit.h>
#import "HKBLightAccessoryLIFX.h"


@interface HKBLIFXDiscoveryService () <LFXLightCollectionObserver, LFXLightObserver, HKBLightAccessoryDelegate>
@property (nonatomic, strong) NSMutableDictionary *lightAccessories;
@property (nonatomic, strong) NSMutableDictionary *accessoriesMenuItems;
@end


@implementation HKBLIFXDiscoveryService

-(instancetype)init{
	if (self = [super init]) {
		self.lightAccessories = [NSMutableDictionary dictionary];
		self.accessoriesMenuItems = [NSMutableDictionary dictionary];
	}
	return self;
}


-(NSString*)displayName{
	return @"LIFX";
}

-(NSArray*)allAccesories{
	return [[self.lightAccessories objectEnumerator] allObjects];
}





-(void)startDiscovering{
	[super startDiscovering];
	[[[LFXClient sharedClient] localNetworkContext].allLightsCollection addLightCollectionObserver:self];
}

-(void)stopDiscovering{
	[[[LFXClient sharedClient] localNetworkContext].allLightsCollection removeLightCollectionObserver:self];
	[super stopDiscovering];
}





#pragma mark - LFXLightCollectionObserver

-(void)lightCollection:(LFXLightCollection *)lightCollection didAddLight:(LFXLight *)light{
	[light addLightObserver:self];
	[self addLight:light];
}
-(void)lightCollection:(LFXLightCollection *)lightCollection didRemoveLight:(LFXLight *)light{
	[self removeLight:light];
	[light removeLightObserver:self];
}

#pragma mark LFXLightObserver

-(void)light:(LFXLight *)light didChangeReachability:(LFXDeviceReachability)reachability{
	if (reachability == LFXDeviceReachabilityReachable) {
		[self addLight:light];
	}
	else {
		[self removeLight:light];
	}
}



-(void)addLight:(LFXLight*)lifxLight{
	if (self.lightAccessories[lifxLight.deviceID] != nil || lifxLight.reachability != LFXDeviceReachabilityReachable) {
		return;
	}
	
	// Create light
	HKBLightAccessoryLIFX *light = [[HKBLightAccessoryLIFX alloc] initWithLightBulb:lifxLight];
	light.delegate = self;
	
	self.lightAccessories[lifxLight.deviceID] = light;
	[self.delegate discoveryService:self didDiscoverAccessory:light];
}
-(void)removeLight:(LFXLight*)lifxLight{
	if (self.lightAccessories[lifxLight.deviceID] == nil) { return; }
	
	HKBLightAccessoryLIFX *light = self.lightAccessories[lifxLight.deviceID];
	
	// Get rid of it
	[self.lightAccessories removeObjectForKey:lifxLight.deviceID];
	[self.delegate discoveryService:self didLoseAccessory:light];
}





#pragma mark - NSMenuItem

-(NSMenuItem*)createMenuItemForAccessory:(HKBLightAccessoryLIFX*)accessory{
	NSMenuItem *item = [super createMenuItemForAccessory:accessory];
	[item setTarget:self];
	[item setAction:@selector(toggleLightAccessory:)];
	
	self.accessoriesMenuItems[accessory.serialNumber] = item;
	
	[self updateMenuItemState:item];
	return item;
}

-(void)toggleLightAccessory:(NSMenuItem*)item{
	HKBLightAccessoryLIFX *lightAccessory = item.representedObject;
	lightAccessory.powerState = !lightAccessory.powerState;
	[self updateMenuItemState:item];
}

-(void)updateMenuItemState:(NSMenuItem*)item{
	HKBLightAccessoryLIFX *lightAccessory = item.representedObject;
	item.state = lightAccessory.powerState ? NSOnState : NSOffState;
}



#pragma mark - HKBLightAccessoryDelegate

-(void)lightAccessory:(HKBLightAccessory*)light didChangePowerState:(BOOL)powerState{
	NSMenuItem *item = self.accessoriesMenuItems[light.serialNumber];
	[self updateMenuItemState:item];
}

@end

